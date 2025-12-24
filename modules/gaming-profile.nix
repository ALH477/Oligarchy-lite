# modules/gaming-profile.nix
{ config, pkgs, lib, ... }: {
  assertions = [
    {
      assertion = pkgs.stdenv.isx86_64 || pkgs.stdenv.isAarch64;
      message = "Gaming profile is only supported on x86_64 and aarch64 (native builds available). Use the minimal profile on riscv64.";
    }
  ];

  config = lib.mkIf (pkgs.stdenv.isx86_64 || pkgs.stdenv.isAarch64) {
    services.xserver.enable = true;

    environment.systemPackages = with pkgs; [
      xterm
      xbindkeys
      freeglut
      (python3.withPackages (ps: [ ps.pyopengl ]))
      prboom-plus
      freedoom
      zandronum
      openarena
      warfork
      vkquake
      dhewm3
      lutris
      prismlauncher
      minetest
      supertux
      wesnoth
      openttd
      hedgewars
      frozen-bubble
      teeworlds
      neverball
      armagetronad
      freeciv
    ] ++ lib.optionals pkgs.stdenv.isx86_64 [
      steam
    ];

    home-manager.users.user = { pkgs, lib, ... }: {
      home.stateVersion = "25.11";

      home.packages = with pkgs; [
        (writeScriptBin "intro" ''
          #!/usr/bin/env python
          import sys
          from OpenGL.GL import *
          from OpenGL.GLUT import *

          def display():
              glClear(GL_COLOR_BUFFER_BIT)
              glColor3f(0.0, 1.0, 0.0)

              def draw_text(x, y, text):
                  glRasterPos2f(x, y)
                  for c in text:
                      glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, ord(c))

              draw_text(-3.5, 1.5, b"OLIGARCHY NIXOS LITE")
              draw_text(-4.5, 0.8, b"Ultra-lightweight open-source gaming")
              draw_text(-4.0, 0.3, b"for single/dual-core legacy hardware")
              draw_text(-3.0, -0.2, b"Declarative NixOS configuration")
              draw_text(-3.5, -0.8, b"Toddler-simple terminal launcher")
              draw_text(-2.5, -1.4, b"Free games - zero bloat")
              draw_text(-2.0, -2.0, b"Press ESC to return")

              glutSwapBuffers()

          def keyboard(key, x, y):
              if key == b'\x1b':
                  sys.exit()

          glutInit(sys.argv)
          glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB)
          glutInitWindowSize(1024, 768)
          glutCreateWindow(b"Oligarchy NixOS Lite Intro")
          glutFullScreen()
          glClearColor(0.0, 0.0, 0.0, 1.0)
          glutDisplayFunc(display)
          glutKeyboardFunc(keyboard)
          glutMainLoop()
        '')

        (writeScriptBin "toggleintro" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " AUTO-INTRO TOGGLE "
          if [ -f ~/.no_intro ]; then
            rm ~/.no_intro
            echo "Auto-intro now ENABLED"
          else
            touch ~/.no_intro
            echo "Auto-intro now DISABLED"
          fi
          echo
          echo "Reboot to apply change"
          sleep 5
        '')

        (writeScriptBin "doom" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " FREEDOOM "
          echo "Open source classic shooter!"
          sleep 2
          prboom-plus -fullscreen -iwad ${pkgs.freedoom}/share/games/doom/freedoom2.wad
        '')

        (writeScriptBin "multi" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " ZANDRONUM "
          echo "Multiplayer-capable source port"
          sleep 2
          zandronum -iwad ${pkgs.freedoom}/share/games/doom/freedoom2.wad
        '')

        (writeScriptBin "arena" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " OPENARENA "
          echo "Free Quake-style arena shooter"
          sleep 2
          openarena
        '')

        (writeScriptBin "warfork" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " WARFORK "
          echo "Fast-paced open source arena FPS"
          sleep 2
          warfork
        '')

        (writeScriptBin "quake" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " QUAKE "
          echo "Classic Quake engine (vkQuake)"
          echo "Place original Quake files in ~/.quake/id1 if needed"
          sleep 3
          vkquake
        '')

        (writeScriptBin "doom3" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " DOOM 3 "
          echo "Open source Doom 3 engine (dhewm3)"
          echo "Place original Doom 3 data in ~/.doom3/base if needed"
          sleep 3
          dhewm3
        '')

        (writeScriptBin "tux" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " SUPERTUX "
          echo "Jump and collect stars!"
          sleep 2
          supertux --fullscreen
        '')

        (writeScriptBin "voxels" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " MINETEST "
          echo "Build voxel worlds - fully free!"
          sleep 2
          minetest --fullscreen
        '')

        (writeScriptBin "wesnoth" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " WESNOTH "
          echo "Turn-based fantasy strategy"
          sleep 2
          wesnoth --fullscreen
        '')

        (writeScriptBin "tycoon" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " OPENTTD "
          echo "Build transport empire"
          sleep 2
          openttd -f
        '')

        (writeScriptBin "hedge" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " HEDGEWARS "
          echo "Artillery battles with hedgehogs"
          sleep 2
          hedgewars
        '')

        (writeScriptBin "bubble" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " FROZEN BUBBLE "
          echo "Colorful puzzle action"
          sleep 2
          frozen-bubble --fullscreen
        '')

        (writeScriptBin "tee" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " TEEWORLDS "
          echo "Cute 2D shooter fun"
          sleep 2
          teeworlds
        '')

        (writeScriptBin "never" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " NEVERBALL "
          echo "Tilt and roll puzzles"
          sleep 2
          neverball
        '')

        (writeScriptBin "tron" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " ARMAGETRON "
          echo "Tron light cycles"
          sleep 2
          armagetronad
        '')

        (writeScriptBin "civ" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F gay " FREECIV "
          echo "Build your civilization"
          sleep 2
          freeciv-gtk3
        '')

        (writeScriptBin "off" ''
          #!/usr/bin/env bash
          clear
          toilet -f mono12 -F metal " GOODBYE! "
          echo "Shutting down..."
          sleep 2
          sudo systemctl poweroff
        '')
      ];

      home.file.".bash_profile".text = ''
        if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
          if [ ! -f ~/.no_intro ]; then
            intro || true
          fi
          exec startx
        fi
      '';

      home.file.".xinitrc".text = ''
        xbindkeys &
        exec xterm -fullscreen \
          -fa "Monospace" -fs 28 \
          -bg black -fg "#00ff00" \
          -cr "#00ff00" +bdc \
          -hc "#00ff00"
      '';

      home.file.".xbindkeysrc".text = ''
        "doom" mod4 + F1
        "multi" mod4 + F2
        "arena" mod4 + F3
        "warfork" mod4 + F4
        "quake" mod4 + F5
        "doom3" mod4 + F6
        "tux" mod4 + F7
        "voxels" mod4 + F8
        "wesnoth" mod4 + w
        "tycoon" mod4 + t
        "hedge" mod4 + h
        "bubble" mod4 + b
        "tee" mod4 + e
        "never" mod4 + n
        "tron" mod4 + r
        "civ" mod4 + c
        "off" mod4 + o

        "toggleintro" mod4 + Shift + i
        "reboot" mod4 + Shift + r

        "pkill -9 prboom-plus zandronum openarena warfork vkquake dhewm3 minetest supertux wesnoth openttd hedgewars frozen-bubble teeworlds neverball armagetronad freeciv python || true"
          mod4 + F12
      '';

      home.file.".bashrc".text = ''
        print_menu() {
          clear
          toilet -f mono12 -F gay " OLIGARCHY NIXOS LITE "
          toilet -f smblock -F metal "Open Source Gaming"

          local intro_status="ON"
          [ -f ~/.no_intro ] && intro_status="OFF"

          echo
          echo "Auto-Intro: $intro_status (toggleintro + reboot to change)"
          echo
          echo "Type OR Windows + key:"
          echo "  doom     F1  Classic shooter (fully free)"
          echo "  multi    F2  Multiplayer Doom"
          echo "  arena    F3  Quake-style arena"
          echo "  warfork  F4  Fast arena FPS"
          echo "  quake    F5  Quake engine"
          echo "  doom3    F6  Doom 3 engine"
          echo "  tux      F7  Platformer"
          echo "  voxels   F8  Voxel sandbox"
          echo "  wesnoth  W   Fantasy strategy"
          echo "  tycoon   T   Transport empire"
          echo "  hedge    H   Artillery battles"
          echo "  bubble   B   Puzzle shooter"
          echo "  tee      E   2D multiplayer shooter"
          echo "  never    N   Tilt-based puzzle"
          echo "  tron     R   Light cycles"
          echo "  civ      C   Civilization building"
          echo "  off      O   Shutdown"
          echo "  reboot Shift+R Reboot"
          echo
          echo "Stuck? Win + F12 = instant reset"
        }

        PROMPT_COMMAND="print_menu"
        PS1="\n> "
      '';
    };
  };
}
