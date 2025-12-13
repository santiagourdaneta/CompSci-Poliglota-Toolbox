# 🚀 CompSci Poliglota Toolbox: Arquitectura de Alto Rendimiento

Una aplicación web *server-side rendered* (SSR) construida con **Ruby (Sinatra)** que orquesta servicios especializados en C++, Python y Go para lograr un rendimiento óptimo en tareas de computación científica.

## 🌟 La Arquitectura Políglota

El objetivo de este proyecto es demostrar cómo la elección del lenguaje adecuado para cada tarea (el principio **"Choose the Right Tool for the Job"**) crea sistemas más robustos y eficientes. 

| Lenguaje | Tarea Asignada | Mecanismo de Comunicación | Beneficio Clave |
| :--- | :--- | :--- | :--- |
| **Ruby (Sinatra)** | Orquestación web, Routing, Presentación (UI/UX) y Middleware. | N/A | Velocidad de desarrollo, convención (Rack). |
| **C++** | Algoritmos de Ordenamiento (ej. Merge Sort, Quick Sort). | **FFI** (Foreign Function Interface) | Velocidad nativa, baja latencia. |
| **Python** | Cálculo Científico (Eigenvalores, Machine Learning). | **IPC** (Inter-Process Communication) vía Shell/NumPy. | Acceso a librerías maduras (NumPy, SciPy). |
| **Go (GoLang)** | Gestión de Concurrencia, Criptografía, Hashes y Servicios de Red. | **IPC** (Servicio HTTP/gRPC) o **Shell** | Eficiencia en concurrencia y gestión de memoria. |

## 🛠️ Instalación y Requisitos

Asegúrese de tener instalados los siguientes componentes:

* **Ruby 3.0+**
* **Git**
* **Python 3.8+** (con NumPy/SciPy instalados en un `.venv`)
* **Go 1.18+**
* **GCC/MinGW** (Para compilar C++ y las librerías FFI)

### Pasos de Configuración

1.  **Clonar el Repositorio:**
    ```bash
    git clone [https://github.com/santiagourdaneta/CompSci-Poliglota-Toolbox] 
    cd CompSci-Poliglota-Toolbox
    ```

2.  **Instalar Dependencias de Ruby:**
    ```bash
    bundle install
    ```

3.  **Configurar el Entorno Virtual de Python:**
    ```bash
    # (Asumiendo que ya tiene un .venv/python configurado con NumPy)
    source .venv/python/Scripts/activate # O use 'source .venv/python/bin/activate' en Unix
    pip install numpy
    deactivate
    ```

4.  **Compilar la Librería C++ (FFI):**

5.  **Compilar el Servicio Go (Por Hacer):**


### 🚀 Ejecución

Inicie la aplicación web usando Puma a través de Bundler:

```bash
bundle exec puma

CompSciToolbox/
├── app/
│   ├── app.rb              # La aplicación Sinatra y el orquestador principal
│   └── views/
├── config.ru               # Rack handler (Puma)
├── Gemfile
├── lib/
│   ├── compsci_core.rb     # Wrapper FFI para C++
│   ├── math_calculator.rb  # Wrapper IPC para Python
│   └── go_service.rb       # Wrapper IPC para Go (futuro)
├── services/
│   ├── cpp_fast_algs/     # Código fuente C++
│   ├── python_ai_calc/     # Código fuente Python (main.py)
│   └── go_crypto_service/  # Código fuente Go (futuro)
└── public/
    └── assets/

📜 Licencia
Este proyecto está bajo la Licencia MIT.


Temas/Etiquetas (Topics/Tags)   

Ruby Sinatra FFI Poliglota Go Python NumPy C++ High-Performance Web-Architecture

Hashtags para Redes 
 
#PolyglotArchitecture #Ruby #GoLang #FFI #CompSci #HighPerformanceComputing #Sinatra