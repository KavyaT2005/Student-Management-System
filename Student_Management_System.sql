import datetime
import sqlite3
import ctypes
from tkinter import *
from tkinter import ttk
import tkinter.messagebox as mb
from tkcalendar import DateEntry

# ---------------- SYSTEM CONFIG ---------------- #
user32 = ctypes.windll.user32
xpos = int((user32.GetSystemMetrics(0) - 1080) / 2)
ypos = int((user32.GetSystemMetrics(1) - 600) / 2)

headlabelfont = ("Arial", 15, "bold")
labelfont = ("Calibri", 14)
entryfont = ("Calibri", 12)

# ---------------- DATABASE ---------------- #
connector = sqlite3.connect("school.db")
cursor = connector.cursor()

connector.execute("""
CREATE TABLE IF NOT EXISTS MANAGEMENT(
    STUDENT_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    NAME TEXT,
    PHONE_NO TEXT,
    GENDER TEXT,
    DOB TEXT,
    DEPARTMENT TEXT,
    TOTALFEES TEXT
)
""")

connector.execute("""
CREATE TABLE IF NOT EXISTS FEES(
    BILL_NO INTEGER PRIMARY KEY AUTOINCREMENT,
    STUDENT_ID INTEGER,
    BILL_DATE TEXT,
    AMOUNT TEXT
)
""")

# ---------------- GLOBAL VARIABLES ---------------- #
rows = []
currentwindow = ""

# ---------------- UTILITY FUNCTIONS ---------------- #
def reset_fields():
    name_strvar.set("")
    contact_strvar.set("")
    gender_strvar.set("")
    department_strvar.set("")
    total.set("")
    dob.set_date(datetime.datetime.now().date())


def display_records():
    tree.delete(*tree.get_children())
    data = connector.execute("SELECT * FROM MANAGEMENT").fetchall()
    for record in data:
        tree.insert("", END, values=record)


# ---------------- STUDENT FUNCTIONS ---------------- #
def add_record():
    name = name_strvar.get()
    contact = contact_strvar.get()
    gender = gender_strvar.get()
    dobv = dob.get_date()
    dept = department_strvar.get()
    fees = total.get()

    if not all([name, contact, gender, dobv, dept, fees]):
        mb.showerror("Error", "Please fill all fields")
        return

    connector.execute(
        "INSERT INTO MANAGEMENT (NAME, PHONE_NO, GENDER, DOB, DEPARTMENT, TOTALFEES) VALUES (?,?,?,?,?,?)",
        (name, contact, gender, dobv, dept, fees),
    )
    connector.commit()

    mb.showinfo("Success", "Student record added")
    reset_fields()
    display_records()


def remove_record():
    if not tree.selection():
        mb.showerror("Error", "Select a record")
        return

    item = tree.item(tree.focus())["values"]
    connector.execute("DELETE FROM MANAGEMENT WHERE STUDENT_ID=?", (item[0],))
    connector.commit()

    display_records()


def view_record():
    if not tree.selection():
        mb.showinfo("Info", "Select a student")
        return

    item = tree.item(tree.focus())["values"]

    name_strvar.set(item[1])
    contact_strvar.set(item[2])
    gender_strvar.set(item[3])
    dob.set_date(item[4])
    department_strvar.set(item[5])
    total.set(item[6])


# ---------------- MAIN WINDOW ---------------- #
def mainwindow():
    global main, tree, name_strvar, contact_strvar
    global gender_strvar, department_strvar, total, dob

    main = Tk()
    main.title("Student Management System")
    main.geometry(f"1080x600+{xpos}+{ypos}")
    main.resizable(False, False)

    name_strvar = StringVar()
    contact_strvar = StringVar()
    gender_strvar = StringVar()
    department_strvar = StringVar()
    total = StringVar()

    Label(main, text="STUDENT MANAGEMENT SYSTEM",
          font=headlabelfont, bg="SpringGreen").pack(fill=X)

    # -------- LEFT FRAME -------- #
    left = Frame(main, bg="MediumSpringGreen")
    left.place(x=0, y=40, relwidth=0.25, relheight=1)

    Label(left, text="Name").pack()
    Entry(left, textvariable=name_strvar).pack()

    Label(left, text="Mobile").pack()
    Entry(left, textvariable=contact_strvar).pack()

    Label(left, text="Gender").pack()
    OptionMenu(left, gender_strvar, "Male", "Female").pack()

    Label(left, text="DOB").pack()
    dob = DateEntry(left)
    dob.pack()

    Label(left, text="Department").pack()
    Entry(left, textvariable=department_strvar).pack()

    Label(left, text="Total Fees").pack()
    Entry(left, textvariable=total).pack()

    # -------- CENTER FRAME -------- #
    center = Frame(main)
    center.place(relx=0.25, y=40, relwidth=0.2)

    Button(center, text="Add", command=add_record).pack(pady=5)
    Button(center, text="Delete", command=remove_record).pack(pady=5)
    Button(center, text="View", command=view_record).pack(pady=5)
    Button(center, text="Reset", command=reset_fields).pack(pady=5)

    # -------- RIGHT FRAME -------- #
    right = Frame(main)
    right.place(relx=0.45, y=40, relwidth=0.55, relheight=1)

    tree = ttk.Treeview(
        right,
        columns=("ID", "Name", "Phone", "Gender", "DOB", "Dept", "Fees"),
        show="headings",
    )

    for col in tree["columns"]:
        tree.heading(col, text=col)

    tree.pack(fill=BOTH, expand=True)
    display_records()

    main.mainloop()


# ---------------- START APP ---------------- #
mainwindow()
