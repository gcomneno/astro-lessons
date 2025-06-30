#!/bin/bash

# Verifica argomenti
if [ $# -lt 2 ]; then
  echo "Uso: ./mklesson.sh categoria \"Titolo della lezione\""
  echo "Esempio: ./mklesson.sh meta \"Setup Ambiente VirtualBox\""
  exit 1
fi

# Categoria e titolo
CATEGORY=$1
TITLE=$2

# Data odierna
DATE=$(date +%Y-%m-%d)

# Slug dal titolo
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

# Nome file
FILENAME="${DATE}-${SLUG}.md"

# Percorso completo
FULLPATH="./content/${CATEGORY}/${FILENAME}"

# Crea struttura se non esiste
mkdir -p "./content/${CATEGORY}"

# Crea file con frontmatter
cat > "$FULLPATH" <<EOF
---
title: "$TITLE"
slug: "$SLUG"
description: ""
---

## ✏️ Contenuto

Scrivi qui la tua lezione...
EOF

echo "✅ File creato: $FULLPATH"
