# sentiment-classification
Proyecto final de Análisis de Sentimiento - Inteligencia Artificial 2

### Lenguajes y librerías a descargar 

1. Python
    * requests
2. R
    * tm
    * plyr
    * class
    * e1071
    * maxent

### Cómo correr el proyecto

En la carpeta _src/_ correr el siguiente comando:

```
$ Rscript main.r <algorithm>
```

Donde algorithm es:

* 1 -> K-Nearest Neighbor
* 2 -> Support Vector Machines
* 3 -> Max Entropy Classifier


### Organización del repositorio

_data/_ : Donde se encuentran los conjuntos de datos disponibles para este proyecto.

_docs/_ : Documentos necesarios para el proyecto.

_results/_ : Los resultados de las corridas de los algoritmos en formato RData.

_src/_ : Donde está el código fuente.
