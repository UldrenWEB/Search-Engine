# Explicacion

**Este** **Script** de **Bash** trata sobre crear un _buscador de maquinas_ _Virtuales_ de la Plataforma **HackTheBox** y así **filtrar** sobre el tipo de maquina, su dificultad, entre otros. 

# Pasos para lograr crear un Script similar

1. Primero se debe _hacer una petición a la pagina en cuestion_ para saber donde esta toda la información que necesitamos. (De las maquinas)
    - `curl -s -X GET https://htbmachines.github.io`
2. Identificar cual es el **Recurso** que utiliza para obtener la información.
    - `curl -s -X GET https://htbmachines.github.io/bundle.js`
3. **Verificar** que sea el **Recurso** que queremos filtrando, asi identificamos si la informacion que contiene es la que requerimos.
    - `curl -s -X GET https://htbmachines.github.io/bundle.js | grep "Tentacle"`
4. Posteriormente, debemos _traernos todo ese Recurso_ nuestro equipo para que se trabaje de una manera mas Rápida y **eficiente** al efectuar una búsqueda al recurso.
```bash 
#Nos traemos el recurso requerido a nuestra maquina
curl -s -X GET https://htbmachines.github.io/bundle.js > bundle.js

#Le aplicamos un formateo
cat bundle.js | js-beautify | sponge bundle.js

#Cargamos todo el codigo formateado
```
5. Por ultimo se debe filtrar y extraer la informacion que se requiere para poder crear nuestro buscador con herramientas como, **cut**, **awk**, **grep**, **tr**, **sed**, entre otros

# Explicacion de comando para archivo (Basico Linux)

- sponge: Este comando es necesario para poder aplicar cambios o formateos a un archivo y _**cargar asi el mismo archivo con las modificacion**_, si utilizas otra herramienta como **tee** o **>**, esto hara que el archivo quede vacio debido a un error.
- cut: Este comando te permite realizar, tratados de cadenas, filtros o sustituciones, entre otros.
- awk: Este comando similar al **cut** pero mas poderoso, te permite aplicar logica para el tratado y filtrado de la cadena.
- grep: Este comando es para poder hacer **busquedas precisas**, mediante un caractateres o expresiones regulares para poder filtrar correctamente en un archivo, cadena, entre otros. Este comando es sumamente fundamental para desarrollar este Script.

