# 🛡️ SafeClub - Decentralized DAO Vault

SafeClub est une plateforme de **DAO (Organisation Autonome Décentralisée)** simplifiée. Elle permet à une communauté de membres de mettre leurs fonds en commun dans un "Vault" sécurisé et de gérer les dépenses via un système de vote démocratique.

## ✨ Caractéristiques principales

- **Trésorerie Décentralisée** : Coffre-fort sécurisé pour les dépôts en Ether (ETH).
- **Gestion des Membres** : Contrôle d'accès (Admin uniquement) pour ajouter ou retirer des membres.
- **Propositions Démocratiques** : Tout membre peut proposer un transfert de fonds.
- **Système de Vote** : Système de vote "Oui/Non" transparent pour les membres.
- **Exécution Automatisée** : Les propositions ne sont exécutables que si la majorité est atteinte et que le délai de vote est écoulé.
- **Interface Moderne** : UI élégante et responsive construite avec HTML/CSS et Ethers.js.

## 🛠️ Stack Technique

- **Smart Contract** : Solidity (0.8.20)
- **Framework de Développement** : Hardhat
- **Bibliothèques** : OpenZeppelin (Ownable, ReentrancyGuard)
- **Frontend** : HTML5, Vanilla CSS, JavaScript
- **Interaction Blockchain** : Ethers.js (v6)
- **Tests** : Chai & Mocha

## 🚀 Installation et Utilisation

### Prérequis

- [Node.js](https://nodejs.org/) (v16+)
- Extension [MetaMask](https://metamask.io/) installée sur votre navigateur.

### Installation

1. **Cloner le projet** :
   ```bash
   git clone https://github.com/votre-compte/safeclub.git
   cd safeclub
   ```

2. **Installer les dépendances** :
   ```bash
   npm install
   ```

### Développement Local

1. **Lancer le nœud Hardhat** :
   Simule une blockchain Ethereum en local.
   ```bash
   npx hardhat node
   ```

2. **Déployer le Smart Contract** :
   Dans un nouveau terminal, déployez le contrat sur votre nœud local.
   ```bash
   npx hardhat run scripts/deploy.js --network localhost
   ```
   *Note : Copiez l'adresse du contrat affichée et mettez à jour `CONTRACT_ADDRESS` dans `frontend/index.html` si nécessaire.*

3. **Lancer l'Interface** :
   Ouvrez le fichier `frontend/index.html` dans votre navigateur (ou utilisez l'extension "Live Server" de VS Code).

4. **Connecter MetaMask** :
   - Connectez MetaMask au réseau **Localhost 8545**.
   - Importez l'une des clés privées affichées par `npx hardhat node` pour tester avec les comptes membres.

## 🧪 Tests

Lancez la suite de tests pour vérifier le bon fonctionnement du contrat :
```bash
npx hardhat test
```

## 📜 Fonctionnement du Smart Contract

Le contrat `SafeClub.sol` gère les étapes suivantes :

- `deposit()` : Permet à n'importe qui d'ajouter de l'ETH au coffre.
- `createProposal()` : Réservé aux membres ; définit un destinataire, un montant et une date limite.
- `vote()` : Les membres peuvent voter une seule fois par proposition.
- `execute()` : Vérifie si le délai est passé, si la majorité est atteinte et si les fonds sont suffisants avant d'envoyer l'argent.

## 🔒 Sécurité

- **ReentrancyGuard** : Empêche les attaques de réentrée lors des transferts de fonds.
- **Ownable** : Contrôles administratifs pour la gestion des membres.
- **Validation des entrées** : Empêche l'utilisation d'adresses invalides (0x0) ou de montants nuls.

---
Développé pour la démonstration de gouvernance décentralisée.
