# cdp_eval.py <js> : evaluate JS in the app's (first) Android WebView page through the DevTools socket
# (adb forward tcp:9333 localabstract:webview_devtools_remote_<pid> is set up by cdp_eval.sh)
import asyncio, json, sys, urllib.request
import websockets
js = sys.argv[1]
pages = json.load(urllib.request.urlopen("http://127.0.0.1:9333/json"))
async def main():
    async with websockets.connect(pages[0]["webSocketDebuggerUrl"], max_size=None) as ws:
        await ws.send(json.dumps({"id": 1, "method": "Runtime.evaluate", "params": {"expression": js, "returnByValue": True}}))
        while True:
            m = json.loads(await ws.recv())
            if m.get("id") == 1:
                print(m["result"].get("result", {}).get("value", m)); break
asyncio.run(main())
