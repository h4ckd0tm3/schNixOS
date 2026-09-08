APP = bin/wifi_ssid.app/Contents

$(APP)/MacOS/wifi_ssid: wifi_ssid.m Info.plist
	mkdir -p $(APP)/MacOS
	cp Info.plist $(APP)/Info.plist
	clang -O3 -fobjc-arc -framework Foundation -framework CoreLocation -framework CoreWLAN $< -o $@
