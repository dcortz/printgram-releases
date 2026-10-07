#!/bin/bash
# ============================================================
#  PrintGram — instalar (ou atualizar) neste Mac. Sem código, sem compilar.
#  Terminal:  curl -fsSL https://raw.githubusercontent.com/dcortz/printgram-releases/main/instalar.sh | bash
# ============================================================
set -e
REL="dcortz/printgram-releases"
DEST="/Applications/PrintGram.app"
TMP="$(mktemp -d)"
echo "▸ lendo a versão na nuvem…"
curl -fsSL "https://raw.githubusercontent.com/$REL/main/versao.json" -o "$TMP/versao.json"
URL="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["url"])' "$TMP/versao.json")"
VER="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["versao"])' "$TMP/versao.json")"
echo "▸ baixando PrintGram $VER…"
curl -fL --progress-bar "$URL" -o "$TMP/PrintGram.zip"
echo "▸ instalando em $DEST…"
ditto -xk "$TMP/PrintGram.zip" "$TMP/app"
[ -w /Applications ] || { echo "   (precisa da sua senha para escrever em /Applications)"; SUDO=sudo; }
pkill -x PrintGram 2>/dev/null || true
${SUDO:-} rm -rf "$DEST"
${SUDO:-} mv "$TMP/app/PrintGram.app" "$DEST"
${SUDO:-} xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true
rm -rf "$TMP"
# abre sozinho no login
mkdir -p ~/Library/LaunchAgents
cat > ~/Library/LaunchAgents/br.gravital.printgram.plist <<P
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>Label</key><string>br.gravital.printgram</string>
<key>ProgramArguments</key><array><string>/usr/bin/open</string><string>-a</string><string>/Applications/PrintGram.app</string></array>
<key>RunAtLoad</key><true/></dict></plist>
P
echo "✅ PrintGram $VER instalado. Abrindo…"
open "$DEST"
echo "   1) Aceite a permissão de Gravação de Tela e reabra o app pelo P da barra de menu ▸ Sair."
echo "   2) Menu P ▸ Chave da API… e cole a chave da OpenAI (fica no Chaveiro deste Mac)."
echo "   3) Atalho: ⌥P. Daqui em diante o app avisa sozinho quando houver versão nova."
