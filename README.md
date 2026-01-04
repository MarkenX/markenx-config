# MarkenX Config

## Descripcion

Este repositorio contiene la configuracion de infraestructura como codigo (IaC) para desplegar el sistema MarkenX en Kubernetes utilizando ArgoCD como herramienta de GitOps.

El sistema consta de dos aplicaciones principales:
- **Keycloak**: Servidor de autenticacion y autorizacion con su base de datos PostgreSQL
- **MarkenX API**: Backend Spring Boot con su base de datos MySQL

## Tecnologias

- **Kubernetes**: Orquestacion de contenedores
- **ArgoCD**: Despliegue continuo siguiendo principios GitOps
- **Kustomize**: Gestion de configuraciones de Kubernetes
- **Minikube**: Cluster local de Kubernetes para desarrollo
- **Keycloak Operator**: Gestion del ciclo de vida de Keycloak
- **PostgreSQL**: Base de datos para Keycloak
- **MySQL**: Base de datos para MarkenX API
- **NGINX Ingress Controller**: Controlador de ingress para acceso externo

## Prerequisitos

- [Minikube](https://minikube.sigs.k8s.io/docs/start/) instalado
- [kubectl](https://kubernetes.io/docs/tasks/tools/) instalado
- [Make](https://www.gnu.org/software/make/) instalado
- Git

## Despliegue

### 1. Iniciar Minikube

```bash
minikube start
```

### 2. Instalar ArgoCD

Desde la raiz del repositorio:

```bash
make argocd
```

Este comando:
- Crea el namespace `argocd`
- Instala los manifiestos de ArgoCD
- Espera a que el controlador este listo

### 3. Desplegar las aplicaciones

```bash
make deploy
```

Este comando aplica las aplicaciones de ArgoCD que despliegan:
- NGINX Ingress Controller
- Keycloak (operador, instancia, realm)
- MarkenX API

## Acceder a ArgoCD

Para acceder a la interfaz web de ArgoCD, ejecutar los siguientes comandos desde el directorio `argocd/`:

### Obtener la contrasena de admin

```bash
cd argocd
make get-password
```

### Iniciar port-forward

```bash
cd argocd
make port-forward
```

Luego acceder a: http://localhost:8085

- Usuario: `admin`
- Contrasena: (la obtenida con `make get-password`)

## Estructura del Repositorio

```
markenx-config/
├── Makefile              # Comandos principales
├── argocd/
│   └── Makefile          # Comandos de ArgoCD
└── k8s/
    ├── Makefile          # Comandos de Kubernetes
    └── base/
        ├── argocd/       # Aplicaciones de ArgoCD
        ├── api/          # MarkenX API + MySQL
        ├── keycloak/     # Keycloak + PostgreSQL
        └── nginx/        # Ingress Controller
```

## Comandos Disponibles

### Raiz del proyecto

| Comando | Descripcion |
|---------|-------------|
| `make argocd` | Instala ArgoCD en el cluster |
| `make deploy` | Despliega las aplicaciones via ArgoCD |

### Directorio argocd/

| Comando | Descripcion |
|---------|-------------|
| `make install` | Instala ArgoCD |
| `make status` | Muestra el estado de ArgoCD |
| `make get-password` | Obtiene la contrasena de admin |
| `make port-forward` | Inicia port-forward al servidor de ArgoCD |
| `make delete` | Elimina ArgoCD |

### Directorio k8s/

| Comando | Descripcion |
|---------|-------------|
| `make deploy` | Despliega las aplicaciones |
| `make delete` | Elimina las aplicaciones |
| `make status` | Muestra el estado de los recursos |
| `make logs` | Muestra los logs de la API |
| `make restart` | Reinicia la API |

## Acceso a las Aplicaciones

Configurar en `/etc/hosts` (Linux/Mac) o `C:\Windows\System32\drivers\etc\hosts` (Windows):

```
127.0.0.1 keycloak.local
127.0.0.1 markenx-api.local
```

URLs:
- **Keycloak**: http://keycloak.local
- **MarkenX API**: http://markenx-api.local/api/v1
