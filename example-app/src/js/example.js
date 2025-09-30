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

    // if (document.getElementById("verboseLogging")) {
    //     options.verboseLogging = document.getElementById("verboseLogging").checked
    // }

    const result = await window.execute("initialize", options)
}

window.testIsInitialized = async () => {
    const options = {}

    const result = await window.execute("isInitialized", options)
}

window.testStart = async () => {
    const options = {}

    if (document.getElementById("peerID") && document.getElementById("peerID").value.length > 0) {
        options.peerID = document.getElementById("peerID").value
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

    if (document.getElementById("data") && document.getElementById("data").value.length > 0) {
        options.data = document.getElementById("data").value
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

    if (document.getElementById("background").checked)
        permissions.push('background')

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

        await Bitchat.addListener('onConnected',
            (event) => {
                logEvent(`onConnected(${JSON.stringify(event) || ""})`)

                const peerID = event.peerID

                addOption(peerID, peerID)
            }),
        await Bitchat.addListener('onDisconnected',
            (event) => {
                logEvent(`onDisconnected(${JSON.stringify(event) || ""})`)

                const peerID = event.peerID

                removeOption(peerID)
            }),

        await Bitchat.addListener('onSend',
            (event) => {
                logEvent(`onSend(${JSON.stringify(event) || ""})`)

                const messageID = event.messageID
            }),
        await Bitchat.addListener('onReceive',
            (event) => {
                logEvent(`onReceive(${JSON.stringify(event) || ""})`)

                const messageID = event.messageID
                const data = event.data
                const peerID = event.peerID
            }),

        await Bitchat.addListener('onRSSI',
            (event) => {
                logEvent(`onRSSI(${JSON.stringify(event) || ""})`)

                const peerID = event.peerID
                const rssi = event.rssi
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
