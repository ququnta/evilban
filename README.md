# EVILBAN — an autonomous, free system for automatic IP-range blocking of spammers and attackers

Today, any public server is constantly under attack by scanners, botnets, and spam bots. They:

- Overload hardware and skew analytics
- Can get the website banned by search engines
- Clog logs and generate false activity
- Massively register fake accounts for spam and attacks
- Automatically brute-force passwords and seek vulnerabilities

Bots and attackers rarely use single IP addresses—they typically arrive from entire ranges and subnets, frequently changing addresses.

**Why standard filters are ineffective:**
- Blacklists of IP addresses quickly become outdated
- Captchas, questions, and manual verifications are ineffective against mass attacks

**How EVILBAN helps:**
- Automatically detects and blocks entire IP ranges, not just individual addresses
- Aggregates suspicious subnets and updates lists itself without cloud services or subscriptions
- Operates autonomously and free—no data transferred to external parties

**Result:**  
Your logs and resources are protected; spammers and brute-force bots are blocked before they can harm or clutter your service.  
Administrators gain real control over security instead of endless chasing of new IPs.

---

EVILBAN is a standalone set of bash scripts designed to automatically detect, aggregate, and block spam and bot traffic on your server using `ipset`/`iptables`.  
Unlike proprietary services ([example](https://cliffe.ru/statyi/biterika_spam_resheniye/)), EVILBAN operates fully autonomously, requiring no external APIs, subscriptions, or payments.

## Main advantages

- **Full autonomy:** independent of third-party services or databases; all lists and processing are stored and executed locally.
- **Free and without registration:** no dependency on commercial solutions, licenses, or cloud services.
- **Maximum automation:** IP range updates, aggregation, log processing, response to mass scanning (`ddos-deflate`), and block creation occur automatically via scheduled tasks.
- **Transparency and control:** all configurations, rules, and logs are stored on the server; scripts can be easily adapted to any requirement.

EVILBAN is ideal for hosting providers, VPS, gaming, and email servers, forums, public control panels—anywhere rapid and reliable blocking of suspicious IP ranges is critical.

Installation, setup, cron automation, and support for ipset/iptables operations are described below.

---

## Required system utilities

- grep, head, sed, tail
- awk, sort
- ipset, iptables
- ipcalc
- aggregate, iprange
- python3
- unzip
- [ddos-deflate](https://github.com/jgmdev/ddos-deflate)

---

## Installation of EVILBAN (automatic via `install_evilban.sh`)

1. Unpack the archive.
2. Navigate to the files directory.
3. Execute:
4. Check permissions:
   ```sh
   sudo chmod +x ./install_evilban.sh
   ```
5. Run the installer:
   ```sh
   sudo bash install_evilban.sh
   ```

**Outcome:**
- Scripts and config copied to `/usr/local/evilban`
- Logs will be stored in `/var/log/evilban`
- Path variables moved to `evilban.conf` (see below)
- Cron tasks for CIDR aggregation and DDoS-deflate scanning added automatically.

---

## Configuration Structure (`evilban.conf`)

All paths and critical files are defined here:

```sh
PROVIDERS="/etc/evilban_providers.txt"
BLOCKED_RANGES="/var/log/evilban_blocked_ranges.list"
CHECKED_LOG="/var/log/evilban_checked.log"
LOGDIR="/var/log/evilban"
```

All scripts read these variables via:
```sh
. "$(dirname "$0")/evilban.conf"
```
without hard-coded paths.

---

## Manual Installation (if not using `install_evilban.sh`)

Dependencies installation on Debian/Ubuntu:
```sh
sudo apt-get update
sudo apt-get install -y grep sed ipset iptables ipcalc aggregate iprange python3 unzip
```

Installing ddos-deflate:
```sh
git clone https://github.com/jgmdev/ddos-deflate.git /usr/local/ddos
cd /usr/local/ddos
sudo bash install.sh
```

1. Install required utilities (see above).
2. Copy `.sh`-files, `evilban_providers.txt`, `evilban.conf`, and `README.txt` to `/usr/local/evilban`
3. Create logs directory:
   ```sh
   sudo mkdir -p /var/log/evilban
   ```
4. Check permissions:
   ```sh
   sudo chmod +x /usr/local/evilban/*.sh
   ```
5. Set cron tasks:

---

## Cron tasks

### Range aggregation (once daily)
```cron
0 3 * * * root /usr/local/evilban/evilban_cidr_aggregate.sh >> /var/log/evilban/aggregate.log 2>&1
```

### DDoS scanning (every 5 minutes)
```cron
*/5 * * * * root /usr/local/evilban/evilban_deflate_scan.sh >> /var/log/evilban/deflate_scan.log 2>&1
```

---

## General Operation Overview

- Scripts exclusively use paths and files defined in `evilban.conf`.
- Logs and temporary files are stored in `/var/log/evilban`.
- Correct functioning requires configured and enabled `ipset`/`iptables`.

---

## Licensing

EVILBAN code is free and open for modifications. When distributing, always acknowledge the original developer.

---

## Feedback and Support

Questions and suggestions — via [Telegram](https://t.me/vbsupport.ru) or [forum](https://vbsupport.ru/forum)

---

_End of README (version: 2025-06-10)_