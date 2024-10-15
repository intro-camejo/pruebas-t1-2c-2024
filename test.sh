#!/bin/bash
test_count=0
test_passed=0

printf "Verificando entrega...\n"

archivos_esperados=("acertijo1.sh" "acertijo2.sh" "acertijo3.sh" "acertijo4.sh" "acertijo5.sh" "acertijo6.sh")
parametros_extra_punto_5=(7 4 5 43 20 1)

# Verificamos que todos los archivos fueron entregados
function verificar_entrega {
    for archivo in "${archivos_esperados[@]}"; do
        if [ ! -f "$archivo" ]; then
            printf "Falta el archivo: $archivo\n"
            printf "Volve a realizar la entrega con todos los archivos esperados\n"

            exit 1
        fi
    done
    printf "Todos los scripts esperados están presentes.\n"
}

verificar_entrega

#Crear directorios para las salidas
for i in $(seq 1 ${#archivos_esperados[@]}); do
    mkdir -p "_salida_alumno/$i"
done

function comparar_archivos {
    salida_esperada=$1
    salida_obtenida=$2
    
       # Verificar si el archivo de salida esperada está vacío y el archivo de salida obtenida no existe
    if [ ! -f "$salida_obtenida" ] && [ ! -s "$salida_esperada" ]; then
        return 0  # Prueba válida
    elif diff -w "$salida_esperada" "$salida_obtenida" > /dev/null; then
        return 0  # Prueba válida
    else
        return 1  # Prueba inválida
    fi
}

# Recibe un numero de ejercicio y realiza las pruebas correspondientes
function correr_pruebas {
    ejercicio=$1
    printf "\nCorriendo pruebas para el ejercicio $ejercicio\n"
    cantidad_archivos=$(ls _pruebas_algotron/$ejercicio/test_*.txt 2>/dev/null | wc -l)

    if [ $cantidad_archivos -eq 0 ]; then
        printf "No hay pruebas para el $ejercicio, zafaste!\n"
        return
    fi

    for i in $(seq 1 $cantidad_archivos); do
        printf "\nCorriendo test $i\n"
        ((test_count++))
        entrada="_pruebas_algotron/$ejercicio/test_$i.txt"
        salida_esperada="_pruebas_algotron/$ejercicio/salida_$i.txt"
        salida_obtenida="_salida_alumno/$ejercicio/salida_$i.txt"

        #El ejercicio 5, recibe parametros extra
        if [ $ejercicio -eq 5 ]; then
            bash "${archivos_esperados[$(($ejercicio-1))]}" "$entrada" "${parametros_extra_punto_5[$i-1]}" "$salida_obtenida" >> /dev/null
        else
            bash "${archivos_esperados[$(($ejercicio-1))]}" "$entrada" "$salida_obtenida" >> /dev/null
        fi
        
        # Comparar la salida obtenida con la esperada
        if comparar_archivos "$salida_esperada" "$salida_obtenida"; then
            printf "Test $i: OK :)\n"
            ((test_passed++))
        else
            printf "Test $i: ERROR :(\n"
        fi
    done
}


for i in $(seq 1 ${#archivos_esperados[@]}); do
    correr_pruebas $i
done


printf "\nTests pasados: $test_passed/$test_count\n"

if [ $test_passed -eq $test_count ]; then
    printf "Felicitaciones, todos los tests pasaron!!! :))\n"
    exit 0
else
    printf "Algunos tests fallaron, seguí intentando!\n"
    exit 1
fi