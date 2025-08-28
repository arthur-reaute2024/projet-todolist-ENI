# Déploiement d’une application ToDoList conteneurisée sur AKS

@author

## Présentation du projet

Ce projet DevOps met en production une application ToDoList full-stack, composée d’un frontend Angular et d’un backend Node.js/Express avec base de données MySQL. L’objectif est de maîtriser l’ensemble de la chaîne CI/CD, de l’infrastructure à la supervision, dans un cluster Kubernetes (AKS) provisionné sur Azure via Terraform.

L'application est exposée sur l'URL publique : https://todolist.areaute2024.ovh

## Architecture globale

L’architecture repose sur les éléments suivants :

- **Conteneurisation Docker** : chaque composant (frontend, backend, mysql) est contenu dans un conteneur Docker à partir d’un `Dockerfile` dédié :
  - `frontend/` contient les sources Angular + un `Dockerfile` multi-stage avec NGINX
  - `backend/` contient le code Node.js/Express + son propre `Dockerfile`
- **Test en local** : un fichier `docker-compose.yml` permet de lancer toute l’application localement (frontend, backend, mysql).
- **Cluster Kubernetes (AKS)** :
  - Déploiement des composants dans le namespace `prod` :
    - Frontend : `Deployment` (2 replicas) + `Service`
    - Backend : `Deployment` (2 replicas) + `Service`
    - MySQL : `StatefulSet` (1 replica) + `PersistentVolumeClaim` + `ConfigMap` + `Service`
  - Gestion du trafic via un Ingress NGINX (déployé via manifestes officiels)
  - Certificat TLS valide généré automatiquement via Cert-Manager + Let's Encrypt
  - L'URL `todolist.areaute2024.ovh` pointe vers l'ingress via un enregistrement DNS géré dynamiquement par Terraform et l'API OVH

## Infrastructure as Code (Terraform)

L’infrastructure Azure est provisionnée via Terraform, avec notamment :
- Un cluster AKS
- Un enregistrement DNS (via le provider OVH) : création automatique de `todolist.areaute2024.ovh`
- Des namespaces organisés par fonction : `cert-manager`, `ingress-nginx`, `prod`, `monitoring`

L’infrastructure est versionnée, modulaire, et suit les bonnes pratiques :
- Fichiers `.tf` bien organisés
- Utilisation de `terraform fmt`, `validate` et d’un backend distant
- Aucune donnée sensible en clair

## CI/CD – GitHub Actions

Le déploiement est automatisé via un unique workflow GitHub Actions : `.github/workflows/cicd.yaml`.

Ce pipeline se déclenche à chaque **push d’un tag au format `x.y.z`**, et comporte 3 étapes dépendantes :

1. **Tests unitaires**
   - Frontend (Angular) et backend (Node.js) : exécution des tests
2. **Build & Push des images Docker**
   - Création des images `frontend` et `backend`
   - Push vers DockerHub avec les tags : `latest`, `x.y.z`, et `commit_sha`
3. **Déploiement sur AKS**
   - Application des manifestes Kubernetes présents dans le dossier `k8s/`

Les identifiants DockerHub et les credentials du cluster AKS sont gérés en toute sécurité via les **GitHub Secrets**.

## Déploiement Kubernetes (K8S)

Tous les manifestes sont regroupés dans le dossier `k8s/` :
- Frontend : `Deployment` (2 replicas), `Service`
- Backend : `Deployment` (2 replicas), `Service`
- MySQL : `StatefulSet` (1 replica), `PVC`, `ConfigMap`, `Service`
- Ingress :
  - `IngressClass` + `Ingress` pour l’exposition via NGINX
  - Certificat TLS via `ClusterIssuer` (Let’s Encrypt, production)
  - Déploiement de l'ingress-controller NGINX + Cert-Manager à partir des manifestes officiels
- Namespace `prod` dédié à l’application

L’application est accessible sur **HTTP/HTTPS** via `todolist.areaute2024.ovh` avec un certificat TLS valide.

## Monitoring & Supervision

La supervision est déployée avec **Helmfile**, via la commande :

```bash
helmfile -f monitoring/helmfile-tools-monitoring.yaml apply --interactive
```

- Prometheus collecte les métriques du cluster
- Grafana expose des dashboards fonctionnels :
  - État des pods, nodes, deployments
  - Résilience du cluster, alertes basiques

Grafana est accessible via :

```bash
kubectl port-forward services/grafana 17244:3000 -n monitoring
```

Les composants de monitoring sont déployés dans le namespace monitoring.

## Organisation des namespaces

| Namespace       | Usage                                |
| --------------- | ------------------------------------ |
| `cert-manager`  | Gestion des certificats TLS          |
| `ingress-nginx` | Ingress Controller                   |
| `prod`          | Application ToDoList (FE, BE, MySQL) |
| `monitoring`    | Prometheus + Grafana                 |

Cette séparation facilite la gestion des rôles, la maintenance et la supervision.

## Difficultés rencontrées & solutions

- 🔄 Renouvellement automatique du certificat TLS : configuration du ClusterIssuer via Let's Encrypt et validation DNS correcte via l’enregistrement géré par Terraform + OVH.

- 🐳 Gestion multi-tags dans DockerHub : mise en place du tagging latest, version, commit via le workflow.

- 🔐 Sécurité des credentials CI/CD : tous les secrets (DockerHub, kubeconfig) sont stockés via GitHub Secrets.

- 🔧 Test local unifié : ajout d’un docker-compose.yml pour simplifier le test sans Kubernetes.

## Conclusion

Ce projet démontre une chaîne DevOps complète : infrastructure as code, CI/CD automatisé, déploiement Kubernetes, monitoring, gestion DNS, et sécurisation des secrets. L’organisation en namespaces améliore la lisibilité et la maintenabilité du cluster. Le choix des outils respecte les standards actuels en DevOps, avec une mise en œuvre propre et reproductible.
