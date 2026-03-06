#!/bin/bash
# ============================================
#   PC-CLOUD AUTO SETUP
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

echo "⏳ Esperando que inicie (25s)..."
sleep 25

# ── 2. Instalar dependencias base ─────────
echo "📦 Instalando dependencias base..."
docker exec pc-nube bash -c "apt-get update -qq && apt-get install -y -qq wget curl git nano htop neofetch unzip --no-install-recommends"

# ── 3. Wallpaper ──────────────────────────
echo "🖼️  Aplicando wallpaper..."
docker exec pc-nube bash -c "
  wget -q -O /usr/share/backgrounds/xfce/custom.png 'https://i.imgur.com/Nnlim7a.png' &&
  DISPLAY=:1 xfconf-query -c xfce4-desktop \
    -p /backdrop/screen0/monitorVNC-0/workspace0/last-image \
    -s /usr/share/backgrounds/xfce/custom.png 2>/dev/null || true
" && echo "✅ Wallpaper OK" || echo "⚠️ Wallpaper falló"

# ── 4. RetroArch + cores ──────────────────
echo "🎮 Instalando RetroArch..."
docker exec pc-nube bash -c "
  apt-get install -y -qq retroarch &&
  mkdir -p /config/.config/retroarch/cores &&
  wget -q 'https://buildbot.libretro.com/nightly/linux/x86_64/latest/mgba_libretro.so.zip' -P /tmp &&
  unzip -q /tmp/mgba_libretro.so.zip -d /config/.config/retroarch/cores/ &&
  wget -q 'https://buildbot.libretro.com/nightly/linux/x86_64/latest/melonds_libretro.so.zip' -P /tmp &&
  unzip -q /tmp/melonds_libretro.so.zip -d /config/.config/retroarch/cores/ &&
  wget -q 'https://buildbot.libretro.com/nightly/linux/x86_64/latest/citra_libretro.so.zip' -P /tmp &&
  unzip -q /tmp/citra_libretro.so.zip -d /config/.config/retroarch/cores/
" && echo "✅ RetroArch OK" || echo "⚠️ RetroArch falló"

# ── 5. Super Script keepalive ─────────────
echo "⚙️  Iniciando Super Script..."
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
echo "║  👤 Usuario: forgex                ║"
echo "║  🔑 Password: pc-nube              ║"
echo "║  🎮 RetroArch listo                ║"
echo "╚════════════════════════════════════╝"
