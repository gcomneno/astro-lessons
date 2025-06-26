---
title: "Setup Ambiente di Sviluppo con VirtualBox e Ubuntu"
slug: "setup-virtualbox-ubuntu"
description: "Guida passo-passo per costruire un ambiente di sviluppo moderno all'interno di una VM con Ubuntu e XFCE, evitando l'uso di Docker."
---

## 🎯 Obiettivo

Configurare un ambiente di sviluppo *leggero, stabile e portatile* per lavorare con Astro, PHP, Python e VS Code, utilizzando una macchina virtuale Ubuntu in VirtualBox.

## 🛠️ Prerequisiti

- PC con almeno 4 GB di RAM e CPU dual-core
- VirtualBox installato su Windows 7 o superiore
- ISO Ubuntu Server LTS 22.04.6 (preferibile)

## 🔧 Step-by-step

### 1. Creazione VM

- Avvia VirtualBox, crea nuova VM → Ubuntu (64 bit)
- RAM consigliata: **4 GB**
- CPU: **2 core**
- Disco: **25 GB VDI dinamico**

### 2. Installazione Ubuntu

- Usa la ISO Ubuntu Server LTS
- Installa con profilo minimale (senza Docker)
- Installa successivamente XFCE con:

```bash
sudo apt update && sudo apt install xfce4 xfce4-goodies -y
```

### 3. Guest Additions

- Inserisci l’immagine dal menu VirtualBox
- Monta ed esegui:

```bash
sudo apt install build-essential dkms linux-headers-$(uname -r)
sudo /media/$USER/VBox_GAs_*/VBoxLinuxAdditions.run
```

### 4. Ottimizzazione performance

- Abilita accelerazione 3D + 128MB video
- Abilita PAE/NX
- Assegna 2 core CPU se possibile

### 5. Configurazioni post-installazione

- Installa:
  - Node.js 18
  - PHP CLI
  - Python 3
  - VS Code (deb ufficiale)
- Aggiungi supporto cartelle condivise con:

```bash
sudo usermod -aG vboxsf $USER
```

## 📌 Note Finali

- **Docker non richiesto**
- **Snapshot consigliate**:
  - Dopo SO base
  - Dopo ambiente completo
- Evita tool pesanti su vecchi PC

---

✅ Ambiente pronto per ospitare il tuo progetto *Astro Lessons*!
