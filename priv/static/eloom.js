// This is the Eloom client, which should be imported by user apps.
const Eloom = (function () {
    let config = {
        endpoint: '/eloom/api/track', // set with init()
        writeKey: '', // optional, if needed
        batchSize: 10,
        flushInterval: 5000,
    };
    let userId = null;
    let userProps = {};
    let anonymousId = getOrCreateAnonymousId();
    let eventQueue = [];
    function init({ endpoint, writeKey }) {
        config.endpoint = endpoint;
        config.writeKey = writeKey;
        setInterval(flush, config.flushInterval);
        document.addEventListener('visibilitychange', () => {
            if (document.visibilityState === 'hidden')
                flush();
        });
    }
    function identify(id) {
        userId = id;
    }
    function setUserProperties(props) {
        userProps = { ...userProps, ...props };
    }
    function track(event, properties = {}) {
        const payload = {
            event,
            properties,
            $insert_id: crypto.randomUUID(),
            timestamp: new Date().toISOString(),
            user_id: userId,
            anonymous_id: userId ? null : anonymousId,
            user_properties: userProps,
            url: location.href,
            referrer: document.referrer,
        };
        eventQueue.push(payload);
        if (eventQueue.length >= config.batchSize)
            flush();
    }
    function flush() {
        if (eventQueue.length === 0 || !config.endpoint)
            return;
        const batch = eventQueue.splice(0, config.batchSize);
        const body = JSON.stringify({ batch, writeKey: config.writeKey });
        if (navigator.sendBeacon) {
            const blob = new Blob([body], { type: 'application/json' });
            navigator.sendBeacon(config.endpoint, blob);
        }
        else {
            fetch(config.endpoint, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body,
            }).catch((err) => {
                console.error('Eloom failed to send:', err);
                eventQueue.unshift(...batch); // retry next flush
            });
        }
    }
    function getOrCreateAnonymousId() {
        const key = 'eloom_anonymous_id';
        let id = localStorage.getItem(key);
        if (!id) {
            id = crypto.randomUUID();
            localStorage.setItem(key, id);
        }
        return id;
    }
    return { init, identify, setUserProperties, track, flush };
})();
// Example usage
// Eloom.init({ endpoint: '/eloom/api/track', writeKey: 'abc123' });
// Eloom.identify('user_42');
// Eloom.setUserProperties({ email: 'user@example.com' });
// Eloom.track('button_clicked', { button_id: 'signup' });
export default Eloom;
//# sourceMappingURL=eloom.js.map