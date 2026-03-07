#!/bin/bash
# ============================================
#   PC-CLOUD AUTO SETUP v3 by @j_eliseoo_v
# ============================================
echo "╔════════════════════════════════════╗"
echo "║     PC-CLOUD INICIANDO... 🚀       ║"
echo "╚════════════════════════════════════╝"

# ── 1. Levantar PC-Cloud ──────────────────
echo "🐳 Levantando PC-Cloud..."
docker stop pc-nube 2>/dev/null
docker rm pc-nube 2>/dev/null
docker run -d \
  --name pc-nube \
  -p 3000:3000 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/El_Salvador \
  -e SUBFOLDER=/ \
  -e TITLE=PC-Cloud \
  -e CUSTOM_USER=forgex \
  -e PASSWORD=pc-nube \
  -e LANG=es_SV.UTF-8 \
  -e LANGUAGE=es_SV:es \
  --shm-size="2gb" \
  --memory="3g" \
  --cpus="2" \
  --restart unless-stopped \
  lscr.io/linuxserver/webtop:ubuntu-xfce

echo "⏳ Esperando que inicie (30s)..."
sleep 30

# ── 2. Instalar herramientas ──────────────
echo "📦 Instalando herramientas..."
docker exec pc-nube bash -c "
  apt-get update -qq &&
  apt-get install -y -qq \
    wget curl git nano \
    htop neofetch \
    unzip zip \
    python3 python3-pip \
    nodejs npm \
    net-tools iputils-ping \
    screen tmux \
    fonts-noto-color-emoji \
    mousepad \
    thunar \
    chromium \
    --no-install-recommends
" && echo "✅ Herramientas instaladas" || echo "⚠️ Algo falló"

# ── 3. Chromium en español ────────────────
echo "🌐 Configurando Chromium en español..."
docker exec pc-nube bash -c "
  mkdir -p /config/.config/chromium/Default &&
  cat > /config/.config/chromium/Default/Preferences << 'CHROMEPREF'
{
  \"intl\": {\"accept_languages\": \"es-SV,es,en-US,en\"},
  \"translate_blocked_languages\": [],
  \"translate\": {\"enabled\": true}
}
CHROMEPREF
"

# ── 4. Mensaje de bienvenida (bloc de notas) ──
echo "📝 Creando mensaje de bienvenida..."
docker exec pc-nube bash -c "
mkdir -p /config &&
cat > /config/BIENVENIDA.txt << 'EOF'
╔══════════════════════════════════════════════════════╗
║         BIENVENIDO A PC-CLOUD 🖥️                     ║
║              by @j_eliseoo_v                         ║
╠══════════════════════════════════════════════════════╣
║                                                      ║
║  ✅ Lo que incluye esta PC-Cloud:                    ║
║                                                      ║
║  🌐 Chromium en español                              ║
║  📁 Gestor de archivos Thunar                        ║
║  📝 Bloc de notas Mousepad                           ║
║  🐍 Python 3 + Node.js                               ║
║  💻 Git, Curl, Wget y más                            ║
║  ⚡ Se mantiene activa sola                          ║
║  🔄 Se reinicia automáticamente                      ║
║  🛡️  Keepalive activo (no se apaga)                  ║
║                                                      ║
║  💡 Mejoras vs versión anterior:                     ║
║  - Sin programas innecesarios (más rápida)           ║
║  - Chromium preinstalado en español                  ║
║  - Gestor de archivos mejorado (Thunar)              ║
║  - Se enciende sola al abrir Codespaces              ║
║  - Keepalive automático cada 5 minutos               ║
║                                                      ║
║  📱 Sígueme en TikTok: @j_eliseoo_v                  ║
║  🔗 https://www.tiktok.com/@j_eliseoo_v              ║
║                                                      ║
╚══════════════════════════════════════════════════════╝
EOF
"

# ── 5. Autostart: bienvenida + Chrome al login ──
echo "🚀 Configurando autostart..."
docker exec pc-nube bash -c "
  mkdir -p /config/.config/autostart &&

  cat > /config/.config/autostart/bienvenida.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Bienvenida
Exec=bash -c 'mousepad /config/BIENVENIDA.txt'
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

  cat > /config/.config/autostart/tiktok.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=TikTok
Exec=bash -c 'sleep 3 && chromium --new-window https://www.tiktok.com/@j_eliseoo_v'
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
"

# ── 6. Keepalive dentro del contenedor ────
echo "⚙️  Iniciando keepalive..."
docker exec -d pc-nube bash -c '
  while true; do
    date >> /config/keepalive.log
    sleep 300
  done
'

# ── 7. Keepalive del Codespace ────────────
while true; do
  echo -ne "\r⏰ $(date '+%H:%M:%S') | RAM: $(free -m | awk 'NR==2{printf "%.0f%%", $3*100/$2}') | Disco: $(df -h / | awk 'NR==2{print $5}')"
  docker ps | grep -q "pc-nube" || docker start pc-nube 2>/dev/null
  sleep 240
done &

echo ""
echo "╔════════════════════════════════════╗"
echo "║         TODO LISTO! ✅              ║"
echo "╠════════════════════════════════════╣"
echo "║  🌐 Abre el puerto 3000            ║"
echo "╚════════════════════════════════════╝"
