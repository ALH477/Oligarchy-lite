# modules/python.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.custom.python;
in
{
  options.custom.python = {
    enable = lib.mkEnableOption "Enhanced Python environment with useful libraries";
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };
    networking = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.python3.withPackages (ps: with ps; [
        requests
        beautifulsoup4
        pyyaml
        flask
      ] ++ (lib.optionals cfg.networking [
        netifaces
        zeroconf
        pyserial
        pyusb
      ]) ++ cfg.extraPackages))
    ];

    home-manager.users.user = { ... }: {
      home.file.".bashrc".text = lib.mkAfter ''
        alias py='python3 -q'
        alias flaskrun='flask --app $(ls *.py | head -1) run --host=0.0.0.0 --port=5000'

        alias pyserver='python3 -c "
import socket
s = socket.socket()
s.bind((\"0.0.0.0\", 5000))
s.listen(1)
print(\"Echo server on port 5000\")
conn, addr = s.accept()
while True:
    data = conn.recv(1024)
    if not data: break
    conn.send(data)
conn.close()"'

        alias pyclient='python3 -c "
import socket
s = socket.socket()
s.connect((\"$(hostname -I | awk \"{print \$1}\")\", 5000))
while True:
    msg = input(\"Send: \")
    s.send(msg.encode())
    print(\"Recv:\", s.recv(1024).decode())"'

        alias pyserial-list='python3 -c "
import serial.tools.list_ports
for p in serial.tools.list_ports.comports():
    print(p.device, p.description)"'

        alias pyusb-list='python3 -c "
import usb.core
for dev in usb.core.find(find_all=True):
    print(f\"ID {dev.idVendor:04x}:{dev.idProduct:04x} - {dev.manufacturer} {dev.product}\")"'

        echo "  py            Python REPL"
        echo "  pyserver      Simple TCP echo server"
        echo "  pyclient      Simple TCP client"
        echo "  pyserial-list List USB serial ports"
        echo "  pyusb-list    List USB devices"
      '';
    };
  };
}
