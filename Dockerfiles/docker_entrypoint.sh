#!/bin/sh

if [[ "$MYPASSWD" == "123456" || "$MYPASSWD" == "MY_PASSWORD" ]]; then
    echo please reset your password && exit 1
fi

if [[ "$MYDOMAIN" == "1.1.1.1.nip.io" || "$MYDOMAIN" == "MY_DOMAIN.COM" ]]; then
    echo please reset your domain name && exit 1
fi

# config
cat <<EOF >/etc/caddy/Caddyfile
{
    order trojan before route
    servers :443 {
        listener_wrappers {
            trojan
        }
    }
    trojan {
        caddy
        no_proxy
        users $MYPASSWD
    }
}
:443, $MYDOMAIN {
    trojan {
        connect_method
        websocket
    }
    @host host $MYDOMAIN
    route @host {
        file_server {
            root /usr/share/caddy
        }
    }
}
EOF

rm -f /usr/share/caddy/index.html

cat <<'HTML' >/usr/share/caddy/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to nginx!</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
            line-height: 1.6;
            color: #333;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }
       .container {
            max-width: 800px;
            margin: 40px auto;
            padding: 30px;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1, h2 {
            color: #2c3e50;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 10px;
        }
        p {
            margin-bottom: 1em;
        }
        code {
            background-color: #ecf0f1;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: "Courier New", Courier, monospace;
        }
        pre {
            background-color: #2c3e50;
            color: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
        pre code {
            background-color: transparent;
            padding: 0;
        }
        footer {
            text-align: center;
            margin-top: 40px;
            font-size: 0.9em;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Welcome to nginx!</h1>
        </header>
        <main>
            <p>If you see this page, the nginx web server is successfully installed and working. Further configuration is required.</p>
            
            <h2>My First Post: Hello World!</h2>
            <p>This is the default page for my new server setup. I'm still figuring out how to configure everything, but it's exciting to have a live server on the internet. The plan is to host a few personal projects here.</p>
            <p>For now, here's a classic "Hello, World!" in Python to commemorate the occasion:</p>
            <pre><code>def say_hello():
    print("Hello, World!")

if __name__ == "__main__":
    say_hello()</code></pre>
            <p>Stay tuned for more updates as I get things up and running. The next step is to deploy a simple Flask application and get the domain properly configured with all the necessary DNS records.</p>
        </main>
    </div>
    <footer>
        <p>&copy; 2025 My Personal Server. All rights reserved.</p>
    </footer>
</body>
</html>
HTML

# start
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
