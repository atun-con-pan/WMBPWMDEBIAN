#!/usr/bin/env python3

import tkinter as tk
import sys

def mostrar_alerta(*mensajes):
    # Crear la ventana de alerta
    ventana = tk.Tk()
    ventana.title("Alerta")
    ventana.overrideredirect(True)  # Eliminar decoraciones de la ventana
    ventana.geometry("300x70+1313+50")  # Tamaño y posición de la ventana (ajusta según sea necesario)

    # Configurar el color de fondo de la ventana
    color_fondo_ventana = "#FF5252"  # Rojo advertencia
    ventana.configure(bg=color_fondo_ventana)

    # Concatenar los mensajes
    mensaje_completo = "\n".join(mensajes)

    # Configurar la etiqueta en la ventana
    label = tk.Label(ventana, text=mensaje_completo, font=("Arial", 12), bg=color_fondo_ventana, fg="white")
    label.pack(pady=10)

    # Cerrar la ventana después de 5 segundos
    ventana.after(5000, ventana.destroy)

    # Iniciar el bucle de eventos
    ventana.mainloop()

# Obtener los mensajes desde la línea de comandos
mensajes = sys.argv[1:]

# Ejemplo de uso
if mensajes:
    mostrar_alerta(*mensajes)
else:
    mostrar_alerta("Por favor. Conecta el cargador.\n" "Nivel de batería bajo")
