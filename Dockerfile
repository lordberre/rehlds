FROM debian:bookworm-slim

ARG VERSION
ENV VERSION $VERSION
ARG mod=cstrike
ARG hlds_build=8684
ARG rehlds_version=3.12.0.780
ARG regamedll_version=5.21.0.576
ARG metamod_version=1.3.0.131
ARG whblocker_version=1_5_697
ARG reaimdetector_version=0.2.2
ARG steamcmd_url=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
ARG hlds_url="https://github.com/DevilBoy-eXe/hlds/releases/download/$hlds_build/hlds_build_$hlds_build.zip"
ARG rehlds_url="https://github.com/dreamstalker/rehlds/releases/download/$rehlds_version/rehlds-bin-$rehlds_version.zip"
ARG regamedll_url="https://github.com/s1lentq/ReGameDLL_CS/releases/download/$regamedll_version/regamedll-bin-$regamedll_version.zip"
# ARG metamod_url="https://github.com/Bots-United/metamod-p/releases/download/v$metamod_version/metamod_i686_linux_win32-$metamod_version.tar.xz"
ARG metamod_url="https://github.com/theAsmodai/metamod-r/releases/download/$metamod_version/metamod-bin-$metamod_version.zip"
ARG amxmod_url_with_version=https://www.amxmodx.org/amxxdrop/1.9/amxmodx-1.9.0-git5294-base-linux.tar.gz
ARG amxmod_cstrike_url_with_version=https://www.amxmodx.org/amxxdrop/1.9/amxmodx-1.9.0-dev-git5202-cstrike-linux.tar.gz
ARG anti_cheats="reaimdetector_$reaimdetector_version.tar.gz whblocker_$whblocker_version.tar.gz rechecker_mm_07c95aa.tar.gz"
ARG resources_amxbanslist_url=https://dl.rehlds.ru/metamod/ReChecker/recheker_base/Resources_Checker_Base-amx_ban.zip
## See https://rehlds.ru/

# Persistent paths
VOLUME /opt/steam/hlds/$mod

# WARNING: setlocale('en_US.UTF-8') failed, using locale: 'C'.
# International characters may not work.
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \ 
 && rm -rf /var/lib/apt/lists/* \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ENV LC_ALL en_US.UTF-8

RUN groupadd -r steam && useradd -r -g steam -m -d /opt/steam steam

RUN dpkg --add-architecture i386

# Use "lib32gcc1" for older debian releases
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    lib32gcc-s1 \
    unzip \
    xz-utils \
    zip \
    libsdl2-2.0-0:i386 \
 && apt-get -y autoremove \
 && rm -rf /var/lib/apt/lists/*

USER steam
WORKDIR /opt/steam
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Start by copying data from the current running container or earlier
# COPY --chown=steam:steam ./cstrike_data/ /opt/steam/hlds/$mod
COPY --chown=steam:steam ./lib/hlds.install /opt/steam

RUN curl -sL "$steamcmd_url" | tar xzvf - \
    && ./steamcmd.sh +runscript hlds.install

RUN curl -sLJO "$hlds_url" \
    && unzip -o "hlds_build_$hlds_build.zip" -d "/opt/steam" \
    && rm -rf hlds_build_$hlds_build/libSDL2.so \
    && cp -R "hlds_build_$hlds_build"/* hlds/ \
    && rm -rf "hlds_build_$hlds_build" "hlds_build_$hlds_build.zip"

# Fix error that steamclient.so is missing
RUN mkdir -p "$HOME/.steam" \
    && ln -s /opt/steam/linux32 "$HOME/.steam/sdk32"

# Fix warnings:
# couldn't exec listip.cfg
# couldn't exec banned.cfg
RUN touch /opt/steam/hlds/$mod/listip.cfg
RUN touch /opt/steam/hlds/$mod/banned.cfg

# Install reverse-engineered HLDS
RUN curl -sLJO "$rehlds_url" \
    && unzip -o "rehlds-bin-$rehlds_version.zip" -d "/opt/steam/rehlds" \
    && cp -R /opt/steam/rehlds/bin/linux32/* /opt/steam/hlds/ \
    && rm -rf "rehlds-bin-$rehlds_version.zip" "/opt/steam/rehlds"

# Install ReGameDLL
RUN curl -sLJO "$regamedll_url" \
    && unzip -o "regamedll-bin-$regamedll_version.zip" -d "/opt/steam/regamedll" \
    && cp -R /opt/steam/regamedll/bin/linux32/cstrike/* /opt/steam/hlds/cstrike \
    && rm -rf "regamedll-bin-$regamedll_version.zip" "/opt/steam/regamedll"

# Install Metamod-R
RUN curl -sLJO "$metamod_url" && unzip -o metamod-bin-$metamod_version.zip -d /opt/steam/hlds/$mod/
RUN sed -i 's/dlls\/hl\.so/addons\/metamod\/dlls\/metamod.so/g' /opt/steam/hlds/$mod/liblist.gam

# Install AMX mod X 
RUN curl -sqL "$amxmod_url_with_version" | tar -C /opt/steam/hlds/$mod/ -zxvf - \
    && echo 'linux addons/amxmodx/dlls/amxmodx_mm_i386.so' >> /opt/steam/hlds/$mod/addons/metamod/plugins.ini
RUN curl -sqL "$amxmod_cstrike_url_with_version" | tar -C /opt/steam/hlds/$mod/ -zxvf -
RUN cat /opt/steam/hlds/$mod/mapcycle.txt >> /opt/steam/hlds/$mod/addons/amxmodx/configs/maps.ini

# Install Anti-cheats
RUN mkdir -p /opt/steam/anticheats
COPY --chown=steam:steam lib/anticheats/* /opt/steam/anticheats
RUN echo "Unpacking anti cheat archives: $anti_cheats"
RUN for anticheat in $anti_cheats; do tar xvfz anticheats/$anticheat -C /opt/steam/anticheats;done
RUN mkdir -p /opt/steam/hlds/$mod/addons/whblocker
RUN cp -R /opt/steam/anticheats/whblocker_1_5_697/bin/linux/* /opt/steam/hlds/$mod/addons/whblocker
RUN cp -R /opt/steam/anticheats/linux/* /opt/steam/hlds/$mod/
RUN mkdir -p /opt/steam/hlds/$mod/addons/rechecker
RUN cp -R /opt/steam/anticheats/rechecker_mm_*.so /opt/steam/hlds/$mod/addons/rechecker
RUN cp -R /opt/steam/anticheats/resources.ini /opt/steam/hlds/$mod/addons/rechecker
RUN mkdir -p /opt/steam/hlds/$mod/addons/rechecker/logs
RUN curl -sLJO $resources_amxbanslist_url && unzip -o /opt/steam/Resources_Checker_Base-amx_ban.zip -d /opt/steam/hlds/$mod/addons/rechecker
RUN cp -R /opt/steam/anticheats/linux/addons /opt/steam/hlds/$mod
RUN cd /opt/steam/hlds/$mod/addons/amxmodx/scripting && ./amxxpc reaimdetector.sma
RUN mv /opt/steam/hlds/$mod/addons/amxmodx/scripting/reaimdetector.amxx /opt/steam/hlds/$mod/addons/amxmodx/plugins
# RUN rm -rf "/opt/steam/anticheats"

# Add various configuration
RUN echo "linux addons/rechecker/rechecker_mm_i386.so" >> /opt/steam/hlds/$mod/addons/metamod/plugins.ini
RUN echo "linux addons/whblocker/whblocker_mm_i386.so" >> /opt/steam/hlds/$mod/addons/metamod/plugins.ini
RUN echo "reaimdetector" >> /opt/steam/hlds/$mod/addons/amxmodx/configs/modules.ini
RUN echo "reaimdetector.amxx" >> /opt/steam/hlds/$mod/addons/amxmodx/configs/plugins.ini

# Enabled custom amx plugins
RUN echo "hlstatsx_commands_cstrike.amxx" >> /opt/steam/hlds/$mod/addons/amxmodx/configs/plugins.ini

# RePugMod
RUN echo "linux addons/pugmod/dlls/pugmod_mm.so" >> /opt/steam/hlds/$mod/addons/metamod/plugins.ini

WORKDIR /opt/steam/hlds

# Copy default config
COPY --chown=steam:steam $mod $mod

# Update build log
RUN echo "$(date -Iseconds) Docker build completed for VERSION=$VERSION" >> $mod/DOCKERLOG.log

RUN chmod +x hlds_run hlds_linux

RUN echo 10 > steam_appid.txt

EXPOSE 27016
EXPOSE 27016/udp
EXPOSE 26902/udp

# Start server
ENTRYPOINT ["./hlds_run", "-game cstrike", "-timeout 3", "-pingboost 2"]

# Default start parameters
CMD ["-port 27016", "+maxplayers 16", "+map aim_map"]

# Debug
# USER root
# SHELL ["/bin/bash", "-c"]

