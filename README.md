# Ansible Practice with Terraform-Provisioned EC2 Instances

This project documents my journey of practicing **Ansible** on EC2 instances provisioned via **Terraform**.  
It covers infrastructure creation, configuration management, running ad-hoc commands, writing playbooks, and a **mini project** deploying a custom web page.

---

## 1️⃣ Infrastructure Setup with Terraform

**Description:** Created 4 EC2 instances:

* **1 Ansible Master**
* **3 Managed Nodes**

**Code Example:**

```hcl
# ===== Master Instance =====

resource "aws_instance" "ansible-master" {
    
    depends_on = [ aws_security_group.instance_sg, aws_key_pair.master_key ]
    
    key_name = aws_key_pair.master_key.key_name
    security_groups = [aws_security_group.instance_sg.name]
    instance_type = var.instance_type
    ami = var.ami_id

    root_block_device {
        volume_size =  16
        volume_type = "gp3"
    }
    tags = {
        Name = var.master
        Environment = var.env
    }
}

# ===== 3 Server Instances =====

resource "aws_instance" "ansible-server" {
    count = 3
    
    depends_on = [ aws_security_group.instance_sg, aws_key_pair.server_key ]
    
    key_name = aws_key_pair.server_key.key_name
    security_groups = [aws_security_group.instance_sg.name]
    instance_type = var.instance_type
    ami = var.ami_id

    root_block_device {
        volume_size =  8
        volume_type = "gp3"
    }
    tags = {
        Name = "${var.server}-${count.index + 1}"
        Environment = var.env
    }
}
```
- You can find the whole code in ec2.tf

---

## 2️⃣ Configuring Ansible Master

**Steps:**

* Installed **Ansible** on master:

```bash
sudo apt update && sudo apt install ansible -y
```

* Transferred private key from local to master:

```bash
scp -i my-key.pem my-key.pem ubuntu@<ansible-master-public-ip>:/home/ubuntu/
```

---

## 3️⃣ Inventory File Setup

**Description:** Edited `/etc/ansible/hosts` to include private IPs and variables.

**Example:**

```ini
[servers]
server1 ansible_host=10.0.0.11 ansible_user=ubuntu ansible_ssh_private_key_file=~/my-key.pem
server2 ansible_host=10.0.0.12 ansible_user=ubuntu ansible_ssh_private_key_file=~/my-key.pem
server3 ansible_host=10.0.0.13 ansible_user=ubuntu ansible_ssh_private_key_file=~/my-key.pem
```

---

## 4️⃣ Testing Ansible Connection

```bash
ansible all -m ping
ansible servers -m ping
ansible servers -a "uptime"
```

---

## 5️⃣ Updating Packages

```bash
ansible all -m apt -a "update_cache=yes" --become
```

---

## 6️⃣ Using Groups in Inventory

**Example:**

```ini
[web]
server3 ansible_host=10.0.0.13 ...
```

Run on specific group:

```bash
ansible web -m ping
```

---

## 7️⃣ First Playbook – Show Date & Uptime

**`date_play.yaml`**

```yaml
-
  name: Dates Playbook
  hosts: servers
  tasks:
    - name: Show date
      command: date

    - name: Show uptime
      command: uptime
```

Run:

```bash
ansible-playbook date_play.yaml
```

---

## 8️⃣ Playbook to Install & Start Nginx

```yaml
-
  name: Install Nginx and start it
  hosts: servers
  become: yes
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: latest
    - name: Start Nginx
      service:
        name: nginx
        state: started
        enabled: yes
```

---

## 9️⃣ 🚀 Mini Project – Deploy Custom Web Page

**Goal:** Automate Nginx installation, enable service, and deploy a custom `index.html`.

**`deploy_web.yaml`**

```yaml
-
  name: Install nginx and server static website
  hosts: prd
  become: yes
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: latest

    - name: Start Nginx
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Deploy web page
      copy:
        src: index.html
        dest: /var/www/html/
```

Verify:

```bash
curl http://<public-ip>
```

✅ **Result:** Custom webpage deployed successfully on `web` group server.

---

## 🚀 Here's the project that I deployed

<details>
<summary>📜 View HTML Code</summary>

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Cool Static Page</title>
  <style>
    /* Reset and basic styles */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      font-family: 'Poppins', sans-serif;
    }
    body {
      background: linear-gradient(135deg, #1a1a2e, #16213e, #0f3460);
      color: #fff;
      overflow-x: hidden;
    }
    a {
      color: inherit;
      text-decoration: none;
    }

    /* Navbar */
    nav {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 1rem 3rem;
      background: rgba(0, 0, 0, 0.3);
      backdrop-filter: blur(6px);
      position: fixed;
      width: 100%;
      top: 0;
      z-index: 1000;
    }
    nav .logo {
      font-size: 1.5rem;
      font-weight: 700;
      color: #00fff5;
    }
    nav ul {
      display: flex;
      gap: 2rem;
      list-style: none;
    }
    nav ul li {
      transition: transform 0.3s ease;
    }
    nav ul li:hover {
      transform: scale(1.1);
    }

    /* Hero section */
    .hero {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center;
      padding: 0 2rem;
    }
    .hero h1 {
      font-size: 3rem;
      background: linear-gradient(90deg, #00fff5, #ff00e4);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      animation: fadeIn 1.2s ease-in-out forwards;
    }
    .hero p {
      margin-top: 1rem;
      font-size: 1.2rem;
      color: #dcdcdc;
      animation: fadeIn 2s ease-in-out forwards;
    }
    .hero button {
      margin-top: 2rem;
      padding: 0.8rem 2rem;
      font-size: 1rem;
      border: none;
      border-radius: 25px;
      background: linear-gradient(90deg, #ff00e4, #00fff5);
      color: #fff;
      cursor: pointer;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    .hero button:hover {
      transform: translateY(-3px) scale(1.05);
      box-shadow: 0 5px 20px rgba(0, 255, 245, 0.5);
    }

    /* Features section */
    .features {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 2rem;
      padding: 4rem 3rem;
    }
    .feature-card {
      background: rgba(255, 255, 255, 0.05);
      padding: 2rem;
      border-radius: 15px;
      transition: transform 0.4s ease, background 0.4s ease;
    }
    .feature-card:hover {
      transform: translateY(-10px);
      background: rgba(255, 255, 255, 0.1);
    }
    .feature-card h3 {
      color: #00fff5;
      margin-bottom: 1rem;
    }
    .feature-card p {
      color: #cfcfcf;
      font-size: 0.95rem;
    }

    /* Footer */
    footer {
      text-align: center;
      padding: 1.5rem;
      font-size: 0.9rem;
      background: rgba(0, 0, 0, 0.3);
    }

    /* Animation */
    @keyframes fadeIn {
      from {
        opacity: 0;
        transform: translateY(20px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }
  </style>
</head>
<body>
  <!-- Navbar -->
  <nav>
    <div class="logo">CoolBrand</div>
    <ul>
      <li><a href="#">Home</a></li>
      <li><a href="#">Features</a></li>
      <li><a href="#">About</a></li>
      <li><a href="#">Contact</a></li>
    </ul>
  </nav>

  <!-- Hero -->
  <section class="hero">
    <h1>Welcome to the Future</h1>
    <p>Where design meets innovation. Experience the difference.</p>
    <button>Get Started</button>
  </section>

  <!-- Features -->
  <section class="features">
    <div class="feature-card">
      <h3>🚀 Fast Performance</h3>
      <p>Optimized for speed with smooth user interactions.</p>
    </div>
    <div class="feature-card">
      <h3>🎨 Stunning Design</h3>
      <p>Crafted with modern aesthetics for a professional look.</p>
    </div>
    <div class="feature-card">
      <h3>📱 Fully Responsive</h3>
      <p>Looks amazing on all devices and screen sizes.</p>
    </div>
  </section>

  <!-- Footer -->
  <footer>
    &copy; 2025 CoolBrand. All Rights Reserved.
  </footer>
</body>
</html>
```

</details>```

---
## 📚 Skills Practiced

* Provisioning with Terraform
* Ansible ad-hoc commands
* Inventory management with groups
* Playbook creation
* Automated web deployment

---

## 🛠 Tools Used

* Terraform
* Ansible
* AWS EC2

---

Here’s a **summary section** you can add to the top or bottom of your README so visitors instantly understand the project:

---

## 📖 Summary

This project demonstrates **end-to-end infrastructure automation** using **Terraform** and **Ansible**.
It provisions **4 EC2 instances** (1 Ansible master, 3 managed nodes) on AWS, configures SSH access, and uses Ansible to automate server management.
Tasks include:

* Running **ad-hoc Ansible commands**
* Managing **inventory groups**
* Creating **playbooks** to install and configure software
* Completing a **mini project** that installs Nginx and deploys a custom web page to production servers

**Outcome:** A fully automated workflow from provisioning servers with Terraform to configuring and deploying applications with Ansible.