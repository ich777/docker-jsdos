#!/bin/bash
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

if [ ! -d ${SERVER_DIR}/${APP_NAME} ]; then
	echo "---Installing ${APP_NAME}---"
    if [ ! -f ${SERVER_DIR}/${ZIP_NAME} ]; then
    	echo "---File '${ZIP_NAME}.zip' not found, putting server into sleep mode---"
        sleep infinity
	fi
	cd ${SERVER_DIR}
	npx create-dosbox ${APP_NAME} ${ZIP_NAME}.zip
	cd ${SERVER_DIR}/${APP_NAME}
	sed -i '/fs.extract("/c\\tfs.extract("${ZIP_NAME}.zip" "/GAME").then(() => {' ${SERVER_DIR}/${APP_NAME}/public/index.html
	sed -i '/main(\["-c", "/c\\t\tmain(\["-c", "cd GAME", "-c", "'${START_FILE}'"\])' ${SERVER_DIR}/${APP_NAME}/public/index.html
	echo "\n" | npm install
fi

echo "---Preparing Server---"
echo "---Resolution check---"
if [ -z "${CUSTOM_RES_W} ]; then
	CUSTOM_RES_W=640
fi
if [ -z "${CUSTOM_RES_H} ]; then
	CUSTOM_RES_H=400
fi

if [ "${CUSTOM_RES_W}" -le 639 ]; then
	echo "---Width to low must be a minimal of 640 pixels, correcting to 640...---"
    CUSTOM_RES_W=640
fi

if [ "${CUSTOM_RES_H}" -le 399 ]; then
	echo "---Height to low must be a minimal of 400 pixels, correcting to 400...---"
    CUSTOM_RES_H=400
fi
sed -i '/width: /c\\twidth: ${CUSTOMR_RES_W}px;).then(() => {' ${SERVER_DIR}/${APP_NAME}/public/index.html
sed -i '/height: /c\\theight: ${CUSTOMR_RES_H}px;).then(() => {' ${SERVER_DIR}/${APP_NAME}/public/index.html
chmod -R 777 ${SERVER_DIR}

echo "---Starting Application: ${APP_NAME}---"
cd ${SERVER_DIR}/${APP_NAME}
npm start