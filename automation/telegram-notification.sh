#!/bin/bash
# get variables form gitlab-ci or locals
source ./automation/read_config.sh
source ./automation/docker_getenv.sh

BOT_URL="https://api.telegram.org/bot5881753165:AAEjB95ZRDUW0kRMCzMA7C1yjpHemiGTpiM/sendMessage"
TELEGRAM_CHAT_ID="-1001508340482"
# Set formatting
PARSE_MODE="Markdown"
COMMIT=$(git log -1 --pretty=format:"%s")


# Send message function
send_msg () {
    curl -s -X POST ${BOT_URL} -d chat_id=$TELEGRAM_CHAT_ID \
        -d text="$1" -d parse_mode=${PARSE_MODE}
}


# Call send message with the message
send_msg "
\`---------------------------------------------------\`
Deploy 🚀*${BRANCH_NAME}!*
\`Repository 📦:  ${REPOSITORY}\`
\`Branch 🏷:      ${BRANCH_NAME}\`
\`Version ✅:     ${VERSION}\`
*Commit Msg 💭:* _${COMMIT}_
\`---------------------------------------------------\`
"