graph LR
    A[Soma Smart Shades App] --> B[Soma Connect]
    B --> C[Soma Tilt or Shades]
        
    D[Home Assistant App] --> E[Home Assistant]
    E --> F[Soma HA Integration]
    F --> B

    G[Python script 2] -->|Soma REST API| B

    H[Python script 1] -->|HA REST API| E
