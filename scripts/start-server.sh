#!/bin/bash
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

if [ -z "${APP_NAME}" ]; then
	APP_NAME="CivilisazionBI"
fi
if [ -z "${ZIP_NAME}" ]; then
	ZIP_NAME="civ.zip"
fi
if [ -z "${START_FILE}" ]; then
	START_FILE="CIV.EXE"
fi
if [ -z "${BGND_COLOR}" ]; then
	BGND_C="1f1f1f"
fi
if [ -z "${DOSBOX_V}" ]; then
	DOSBOX_V="wdosbox-nosync"
fi
if [ "$APP_NAME" == "CivilisazionBI" ]; then
	if [ ! -d ${SERVER_DIR}/CivilisatzionBI ]; then 
		cd ${SERVER_DIR}
		if wget https://github.com/ich777/docker-jsdos/raw/master/civ.zip ; then
			echo "---No game specified, downloaded Civilisazion!---"
		else
			echo "---Something went wrong, can't download initial game, putting server in sleep mode---"
			sleep infinity
		fi
	fi
fi

if [ ! -d "${SERVER_DIR}/${APP_NAME}" ]; then
        echo "---Installing '${APP_NAME}'---"
    if [ ! -f "${SERVER_DIR}/${ZIP_NAME}.zip" ]; then
        echo "---File '${ZIP_NAME}.zip' not found, putting server into sleep mode---"
        sleep infinity
    fi
    cd ${SERVER_DIR}
    echo "\n" | npx create-dosbox "${APP_NAME}" "${ZIP_NAME}.zip"
    cd "${SERVER_DIR}/${APP_NAME}"
    npm install
fi

echo "---Preparing Server---"
echo "---Checking if everything is setup correctly---"
FAV=$(grep -e 'favicon.ico' ${SERVER_DIR}/"${APP_NAME}"/public/index.html)
if [ -z "$FAV" ]; then
	echo "---index.html not properly setup, downloading---"
	cd "${SERVER_DIR}/${APP_NAME}/public"
    rm "${SERVER_DIR}/${APP_NAME}/public/index.html"
	if wget https://github.com/ich777/docker-jsdos/raw/master/favicon.ico ; then
		echo "---Sucessfully downloaded 'favicon.ico'---"
	else
		echo "---Something went wrong, can't download 'favicon.ico', continuing---"
		sleep infinity
	fi    
	if wget https://raw.githubusercontent.com/ich777/docker-jsdos/master/config/index.html ; then
		echo "---Sucessfully downloaded 'index.html'---"
	else
		echo "---Something went wrong, can't download 'index.html', putting server in sleep mode---"
		sleep infinity
	fi
fi

echo "---Background color check---"
CUR_BGND_C=$(grep -e 'background-color:' ${SERVER_DIR}/"${APP_NAME}"/public/index.html | cut -d '#' -f2 | sed 's/\;//g')
if [ "$CUR_BGND_C" =! "${BGND_C}"]; then
	echo "---Set background color to: #${BGND_C}---"
	sed -i "/background-color: #/c\      background-color: #${BGND_C};" "${SERVER_DIR}/${APP_NAME}/public/index.html"
else
	echo "---Background color: #${BGND_C}---"
fi
echo "---Dosbox varion check---"
if [ -z "${DOSBOX_V}" ]; then
	DOSBOX_V="wdosbox-nosync"
fi
CUR_DOSBOX_V=$(grep -e 'wdosboxUrl: "' ${SERVER_DIR}/"${APP_NAME}"/public/index.html | cut -d "/" -f2 |cut -d "." -f1)
if [ "$CUR_DOSBOX_V" =! "${DOSBOX_V}"]; then
	echo "---Set Dosbox variant to: ${DOSBOX_V}---"
	sed -i "/Dos(canvas, { wdosboxUrl: \"/c\      Dos(canvas, { wdosboxUrl: \"\/${DOSBOX_V}.js\", autolock: true }).ready((fs, main) => {" "${SERVER_DIR}/${APP_NAME}/public/index.html"
else
	echo "---Dosbox variant: ${DOSBOX_V}---"
fi
echo "---Writing configuration---"
sed -i "/fs.extract(\"/c\        fs.extract(\"${ZIP_NAME}.zip\", \"\/game\").then(() => {" "${SERVER_DIR}/${APP_NAME}/public/index.html"
sed -i "/main(\[\"-c\", \"cd game\", \"/c\        main(\[\"-c\", \"cd game\", \"-c\", \"${START_FILE}\"]).then((ci) => {" "${SERVER_DIR}/${APP_NAME}/public/index.html"

if [ "${FPS_C}" == "true" ]; then
	sed -i"/(function(){var script=document.createElement(/c\    (function(){var script=document.createElement('script');script.onload=function(){var stats=new Stats();document.body.appendChild(stats.dom);requestAnimationFrame(function loop(){stats.update();requestAnimationFrame(loop)});};script.src='//mrdoob.github.io/stats.js/build/stats.min.js';document.head.appendChild(script);})()" "${SERVER_DIR}/${APP_NAME}/public/index.html"
else
	sed -i "/(function(){var script=document.createElement(/c\\/\/    (function(){var script=document.createElement('script');script.onload=function(){var stats=new Stats();document.body.appendChild(stats.dom);requestAnimationFrame(function loop(){stats.update();requestAnimationFrame(loop)});};script.src='//mrdoob.github.io/stats.js/build/stats.min.js';document.head.appendChild(script);})()" "${SERVER_DIR}/${APP_NAME}/public/index.html"
fi
chmod -R 777 ${SERVER_DIR}

echo "---Starting Application: ${APP_NAME}---"
cd "${SERVER_DIR}/${APP_NAME}"
npm start