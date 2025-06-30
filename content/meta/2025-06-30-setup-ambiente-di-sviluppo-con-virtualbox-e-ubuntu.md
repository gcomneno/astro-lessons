---
title: "Setup Ambiente di Sviluppo con VirtualBox e Ubuntu"
slug: "setup-ambiente-di-sviluppo-con-virtualbox-e-ubuntu"
description: ""
---

## 🎯 Obiettivo

Costruire un ambiente di sviluppo *stabile, performante e portatile* utilizzando **Ubuntu Server + XFCE** all'interno di una **VirtualBox VM**. L’ambiente è pensato per supportare stack moderni come **Astro**, **PHP**, **Python**, e **Node.js**, evitando tool pesanti come Docker su sistemi host datati.

## 🧱 Requisiti di sistema

- Host: PC con almeno **4 GB di RAM**, CPU dual-core (consigliato 2 core per la VM)
- Software host: **VirtualBox** (anche su Windows 7)
- ISO: Ubuntu Server 22.04.6 LTS

---

## 🔧 Passaggi step-by-step

### 1. Creazione della VM

- Apri VirtualBox → Nuova VM → Tipo: *Linux*, Versione: *Ubuntu (64-bit)*
- RAM: **4 GB** | CPU: **2 core**
- Disco: **VDI dinamico da 25 GB**
- Abilita:
  - **Accelerazione 3D** con 128MB di memoria video
  - **PAE/NX**

### 2. Installazione di Ubuntu Server

- Usa ISO ufficiale: `ubuntu-22.04.6-live-server-amd64.iso`
- Installa con opzioni minime (senza Docker o Snapd se possibile)
- Non installare GUI in fase iniziale

### 3. Aggiunta dell'ambiente grafico XFCE

Dopo il primo login:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install xfce4 xfce4-goodies lightdm -y
```

## 📂 Cartelle e permessi
Workspace principale: ~/sviluppo

Cartelle condivise con host: /mnt/progetti

Aggiungi l’utente al gruppo vboxsf per accedere ai file condivisi:
sudo usermod -aG vboxsf $USER

## 📌 Lesson Learned
Un ambiente di sviluppo ben configurato in VirtualBox consente anche su macchine datate o sistemi host limitati (es. Windows 7) di ottenere un workflow moderno, efficiente e isolato, pronto per progetti Astro o Laravel.
