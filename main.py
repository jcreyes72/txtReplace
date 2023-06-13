import re
import tkinter as tk
from tkinter import filedialog
import datetime
import os

# File path to store the initials value
INITIALS_FILE = "initials.txt"

def select_file():
    global text, placeholders
    file_path = filedialog.askopenfilename(filetypes=[("Text Files", "*.txt"), ("SQL Files", "*.sql")])
    with open(file_path, "r") as f:
        text = f.read()
    placeholders = sorted(set(re.findall(r'<(.*?)>', text)))
    enter_values(placeholders)


def enter_values(placeholders):
    global entries
    entries = []
    for placeholder in placeholders:
        if placeholder == "date here":
            label = tk.Label(root, text=f"Value for {placeholder}:")
            label.pack(pady=5)
            entry = tk.Entry(root, width=100, justify="center")
            entry.insert(0, datetime.datetime.now().strftime("%m/%d/%Y"))
            entry.pack()
        elif placeholder == "initials":
            label = tk.Label(root, text=f"Value for {placeholder}:")
            label.pack(pady=5)
            entry = tk.Entry(root, width=100, justify="center")
            initials = get_saved_initials()
            if initials:
                entry.insert(0, initials)
            entry.pack()
        else:
            label = tk.Label(root, text=f"Value for {placeholder}:")
            label.pack(pady=5)
            entry = tk.Entry(root, width=100, justify="center")
            entry.pack()
        entries.append(entry)
    button = tk.Button(root, text="Save", command=save_file)
    button.pack(pady=10)


def get_saved_initials():
    if os.path.isfile(INITIALS_FILE):
        with open(INITIALS_FILE, "r") as f:
            initials = f.read().strip()
        return initials
    return ""


def save_initials(initials):
    with open(INITIALS_FILE, "w") as f:
        f.write(initials)


def save_file():
    global text
    values = [entry.get() for entry in entries]
    for placeholder, value in zip(placeholders, values):
        if placeholder == "initials":
            save_initials(value)
        text = text.replace(f"<{placeholder}>", value)
    with filedialog.asksaveasfile(mode="w", defaultextension=".sql") as f:
        f.write(text)
    exit_message()
    # Close the program after 5 seconds
    root.after(5000, root.destroy)


def exit_message():
    for widget in root.winfo_children():
        widget.destroy()
    label = tk.Label(root, text="New .sql file saved with modifications", font=("Arial", 12, "bold"), fg="green")
    label.pack(pady=20)


root = tk.Tk()
root.title("txtReplace")
root.geometry("700x500")

label = tk.Label(root, text="Please select a text file", font=("Arial", 14))
label.pack()

button = tk.Button(root, text="Select File", command=select_file, font=("Arial", 12), padx=10, pady=5, bg="blue", fg="white")
button.pack(pady=10)

root.mainloop()
