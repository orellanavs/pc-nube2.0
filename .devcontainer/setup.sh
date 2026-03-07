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
  \"translate\": {\"enabled\": true}
}
CHROMEPREF
"

# ── 4. Keepalive dentro del contenedor ────
echo "⚙️  Iniciando keepalive..."
docker exec -d pc-nube bash -c '
  while true; do
    date >> /config/keepalive.log
    sleep 300
  done
'

# ── 5. Keepalive del Codespace ────────────
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
