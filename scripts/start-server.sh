
#!/bin/bash
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

if [ -z "${APP_NAME}" ]; then
        echo "---Variable 'APP_NAME' can't be empty, putting server into sleep mode---"
        sleep infinity
fi
if [ -z "${ZIP_NAME}" ]; then
        echo "---Variable 'ZIP_NAME' can't be empty, putting server into sleep mode---"
        sleep infinity
fi
if [ -z "${START_FILE}" ]; then
        echo "---Variable 'START_FILE' can't be empty, putting server into sleep mode---"
        sleep infinity
fi
if [ -z "${BG_COLOR}" ]; then
        echo "---Variable 'BG_COLOR' can't be empty, putting server into sleep mode---"
        sleep infinity
fi
if [ ! -d ${SERVER_DIR}/${APP_NAME} ]; then
        echo "---Installing ${APP_NAME}---"
    if [ ! -f ${SERVER_DIR}/${ZIP_NAME}.zip ]; then
        echo "---File '${ZIP_NAME}.zip' not found, putting server into sleep mode---"
        sleep infinity
        fi
        cd ${SERVER_DIR}
        npx create-dosbox ${APP_NAME} ${ZIP_NAME}.zip
        cd ${SERVER_DIR}/${APP_NAME}
        sed '2a\<style>\n\tbackground-color: #000000;\n}\n</style>' ${SERVER_DIR}/${APP_NAME}/public/index.html
        sed -i '/fs.extract("/c\\tfs.extract("'${ZIP_NAME}'.zip", "/GAME").then(() => {' ${SERVER_DIR}/${APP_NAME}/public/index.html
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
sed -i '/width: /c\\twidth: '${CUSTOMR_RES_W}'px;' ${SERVER_DIR}/${APP_NAME}/public/index.html
sed -i '/height: /c\\theight: '${CUSTOMR_RES_H}'px;' ${SERVER_DIR}/${APP_NAME}/public/index.html
sed '2a\<style>\n\tbackground-color: #'${BG_COLOR}';\n}\n</style>' ${SERVER_DIR}/${APP_NAME}/public/index.html


chmod -R 777 ${SERVER_DIR}

echo "---Starting Application: ${APP_NAME}---"
cd ${SERVER_DIR}/${APP_NAME}
npm start