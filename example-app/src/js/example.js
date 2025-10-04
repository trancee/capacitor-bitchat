import { Bitchat } from '@capacitor-trancee/bitchat'

const scrollToBottom = t => t.scrollTop = t.scrollHeight

const statusEl = document.querySelector("#status")
statusEl.addEventListener("change", () => {
    scrollToBottom(this)
})
const logStatus = (status) => {
    statusEl.value += `${status}` + "\n"
    scrollToBottom(statusEl)
}

const eventsEl = document.querySelector("#events")
eventsEl.addEventListener("change", () => {
    scrollToBottom(this)
})
const logEvent = (event) => {
    eventsEl.value += `⚡ ${event}` + "\n"
    scrollToBottom(eventsEl)
}

window.testInitialize = async () => {
    const options = {}

    const result = await window.execute("initialize", options)

    const peerID = result.peerID

    if (peerID)
        document.getElementById("peerID").value = peerID
}

window.testIsInitialized = async () => {
    const options = {}

    const result = await window.execute("isInitialized", options)
}

window.testStart = async () => {
    const options = {}

    // if (document.getElementById("peerID") && document.getElementById("peerID").value.length > 0) {
    //     options.peerID = document.getElementById("peerID").value
    // }
    if (document.getElementById("announcement") && document.getElementById("announcement").value.length > 0) {
        options.message = document.getElementById("announcement").value
    }

    const result = await window.execute("start", options)
}

window.testIsStarted = async () => {
    const options = {}

    const result = await window.execute("isStarted", options)
}

window.testStop = async () => {
    const options = {}

    document.querySelector("#peers").options.length = 0

    statusEl.value = ""
    eventsEl.value = ""

    const result = await window.execute("stop", options)
}

window.testSend = async () => {
    const options = {}

    if (document.getElementById("message") && document.getElementById("message").value.length > 0) {
        options.message = document.getElementById("message").value
    }
    if (document.getElementById("peers") && document.getElementById("peers").value.length) {
        options.peerID = document.getElementById("peers").value
    }

    const result = await window.execute("send", options)
}

window.testCheckPermissions = async () => {
    const options = {}

    const result = await window.execute("checkPermissions", options)
}

window.testRequestPermissions = async () => {
    const options = {}
    const permissions = []

    if (document.getElementById("bluetooth").checked)
        permissions.push('bluetooth')

    if (document.getElementById("location").checked)
        permissions.push('location')

    if (document.getElementById("battery").checked)
        permissions.push('battery')

    if (permissions.length > 0) {
        options.permissions = permissions
    }

    const result = await window.execute("requestPermissions", options)
}

window.execute = async (method, options) => {
    try {
        options = Object.keys(options).length > 0 ? options : undefined

        logStatus(`⚪ ${method}(${JSON.stringify(options) || ""})`)

        const result = await Bitchat[method](options)

        logStatus(`⚫ ${method}(${JSON.stringify(result) || ""})`)

        return result
    } catch (error) {
        logStatus(`⛔ ${error}`)
    }
}

window.addListeners = async () => {
    await Promise.all([
        await Bitchat.addListener('onStarted',
            (event) => {
                logEvent(`onStarted(${JSON.stringify(event) || ""})`)

                const peerID = event.peerID

                if (peerID)
                    document.getElementById("peerID").value = peerID
            }),
        await Bitchat.addListener('onStopped',
            () => {
                logEvent(`onStopped()`)
            }),

        await Bitchat.addListener('onFound',
            (event) => {
                logEvent(`onFound(${JSON.stringify(event) || ""})`)

                const peerID = event.peerID

                addOption(peerID, peerID)
            }),
        await Bitchat.addListener('onLost',
            (event) => {
                logEvent(`onLost(${JSON.stringify(event) || ""})`)

                const peerID = event.peerID

                removeOption(peerID)
            }),

        await Bitchat.addListener('onConnected',
            (event) => {
                logEvent(`onConnected(${JSON.stringify(event) || ""})`)

                const peerID = event.peerID
            }),
        await Bitchat.addListener('onDisconnected',
            (event) => {
                logEvent(`onDisconnected(${JSON.stringify(event) || ""})`)

                const peerID = event.peerID
            }),

        await Bitchat.addListener('onSent',
            (event) => {
                logEvent(`onSent(${JSON.stringify(event) || ""})`)

                const messageID = event.messageID
                const peerID = event.peerID
            }),
        await Bitchat.addListener('onReceived',
            (event) => {
                logEvent(`onReceived(${JSON.stringify(event) || ""})`)

                const messageID = event.messageID
                const message = event.message
                const peerID = event.peerID
            }),

        await Bitchat.addListener('onRSSIUpdated',
            (event) => {
                logEvent(`onRSSIUpdated(${JSON.stringify(event) || ""})`)

                const peerID = event.peerID
                const rssi = event.rssi

                const option = getOption(peerID)
                if (option) 
                    option.text = `${peerID}  (${rssi} dBm)`
            }),
        await Bitchat.addListener('onPeerListUpdated',
            (event) => {
                logEvent(`onPeerListUpdated(${JSON.stringify(event) || ""})`)

                const peers = event.peers

                const removePeers = {}

                for (const option of document.querySelector("#peers").options) {
                    removePeers[option.value] = true
                }

                peers.forEach(peerID => {
                    delete removePeers[peerID]

                    if (getOption(peerID)) return
                    addOption(peerID, peerID)
                })

                Object.keys(removePeers).forEach(peerID => {
                    removeOption(peerID)
                })
            }),
    ])
}

window.toggle = async (element) => {
    const legend = element.previousElementSibling
    const sibling = element.nextElementSibling

    const title = legend.title

    if (sibling.style.display === "none") {
        sibling.style.display = ""

        legend.title = legend.innerText
        legend.innerText = title

        element.innerText = "▲"
    } else {
        sibling.style.display = "none"

        legend.title = legend.innerText
        legend.innerText = title

        element.innerText = "▼"
    }
}

function addOption(value, text) {
    const select = document.querySelector("#peers")

    // Check if the value already exists
    const exists = Array.from(select.options).some(option => option.value === value)

    if (!exists) {
        const option = document.createElement("option")

        option.value = value
        option.text = text

        select.add(option)
    }
}
function removeOption(value) {
    const option = document.querySelector(`#peers option[value="${CSS.escape(value)}"]`)

    if (option) {
        option.remove()
    }
}
function getOption(value) {
    return document.querySelector(`#peers option[value="${CSS.escape(value)}"]`)
}
