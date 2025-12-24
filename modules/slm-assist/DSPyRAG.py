# MIT LICENCE COPYRIGHT DEMOD LLC
import dspy
import ujson
import faiss
import numpy as np
from sentence_transformers import SentenceTransformer

# Load corpus from specific directory
data_dir = "./data"
corpus_path = f"{data_dir}/ragqa_arena_tech_corpus.jsonl"
max_characters = 6000

with open(corpus_path) as f:
    corpus = [ujson.loads(line)['text'][:max_characters] for line in f]

# Set up local embedder and FAISS index
embedder_model = SentenceTransformer('all-MiniLM-L6-v2')
corpus_embeddings = embedder_model.encode(corpus, normalize_embeddings=True)
dim = corpus_embeddings.shape[1]
index = faiss.IndexFlatIP(dim)
index.add(corpus_embeddings.astype('float32'))

# Custom retriever model that works with DSPy
class LocalRetriever(dspy.Retrieve):
    def __init__(self, embedder, index, corpus, k=5):
        super().__init__(k=k)
        self.embedder = embedder
        self.index = index
        self.corpus = corpus
    
    def forward(self, query_or_queries, k=None, **kwargs):
        k = k or self.k
        queries = [query_or_queries] if isinstance(query_or_queries, str) else query_or_queries
        all_passages = []
        
        for query in queries:
            query_emb = self.embedder.encode(query, normalize_embeddings=True).astype('float32')
            D, I = self.index.search(query_emb.reshape(1, -1), k)
            passages = [self.corpus[idx] for idx in I[0]]
            all_passages.append(passages)
        
        if len(all_passages) == 1:
            return dspy.Prediction(passages=all_passages[0])
        return [dspy.Prediction(passages=passages) for passages in all_passages]

# Initialize retriever
retriever = LocalRetriever(embedder_model, index, corpus, k=5)

# Set up local LM with Ollama
lm = dspy.OllamaLocal(model='llama3', model_type='text', max_tokens=350, temperature=0.7)

# Configure DSPy to use the local LM and retriever
dspy.settings.configure(lm=lm, rm=retriever)

# Define RAG module
class RAG(dspy.Module):
    def __init__(self, num_passages=5):
        super().__init__()
        self.retrieve = dspy.Retrieve(k=num_passages)
        self.generate_answer = dspy.ChainOfThought("context, question -> answer")
    
    def forward(self, question):
        context = self.retrieve(question).passages
        prediction = self.generate_answer(context=context, question=question)
        return dspy.Prediction(context=context, answer=prediction.answer)

# Example usage
if __name__ == "__main__":
    rag = RAG()
    response = rag("what are high memory and low memory on linux?")
    print("Answer:", response.answer)
    print("\nContext:")
    for i, ctx in enumerate(response.context, 1):
        print(f"{i}. {ctx[:200]}...")  # Print first 200 chars of each context
