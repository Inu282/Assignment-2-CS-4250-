#-------------------------------------------------------------------------
# AUTHOR: Alvin Le
# FILENAME: db_connection_solution.py
# SPECIFICATION: Connecting to an SQL database to create categories and documents, update and delte docs, and output the inverted index
# FOR: CS 4250- Assignment #2
# TIME SPENT: Roughly 8-9 hours 
#-----------------------------------------------------------*/

import psycopg2
from psycopg2 import sql
import string

def connectDataBase():
    conn = psycopg2.connect(
        dbname="postgres",
        user="postgres",
        password="postie69",
        host="localhost",
        port = "6969"
    )
    return conn

def createCategory(cur, catId, catName):
    try:
        cur.execute("INSERT INTO Categories (id_cat, name) VALUES (%s, %s);", (catId, catName))
    except psycopg2.Error as e:
        print("Error creating category:", e)

def createDocument(cur, docId, docText, docTitle, docDate, docCat):
    try:
        cur.execute("SELECT id_cat FROM Categories WHERE name = %s;", (docCat,))
        category_row = cur.fetchone()
        
        if category_row is None:
            print(f"Category '{docCat}' does not exist.")
            return

        category_id = category_row[0]
        docText_cleaned = ''.join(char.lower() for char in docText if char.isalnum() or char.isspace())
        cur.execute("INSERT INTO Documents (doc_id, text, title, num_chars, doc_date, id_cat) VALUES (%s, %s, %s, %s, %s, %s);",
                    (docId, docText_cleaned, docTitle, len(docText_cleaned), docDate, category_id))
        terms = set(docText_cleaned.split())

        for term in terms:
            cur.execute("INSERT INTO Terms (term) VALUES (%s) ON CONFLICT DO NOTHING;", (term,))

        for term in terms:
            num_chars = len(term)
            term_count = docText_cleaned.split().count(term)
            cur.execute("INSERT INTO Document_Terms (doc_id, term, term_count, num_chars) VALUES (%s, %s, %s, %s);",
                        (docId, term, term_count, num_chars))
    except psycopg2.Error as e:
        print("Error creating document:", e)


def deleteDocument(cur, docId):
    try:
        cur.execute("SELECT term FROM Document_Terms WHERE doc_id = %s;", (docId,))
        terms = cur.fetchall()

        for term_row in terms:
            term = term_row[0]
            cur.execute("DELETE FROM Document_Terms WHERE doc_id = %s AND term = %s;", (docId, term))
            cur.execute("SELECT COUNT(*) FROM Document_Terms WHERE term = %s;", (term,))
            count = cur.fetchone()[0]

            if count == 0:
                cur.execute("DELETE FROM Terms WHERE term = %s;", (term,))
        cur.execute("DELETE FROM Documents WHERE doc_id = %s;", (docId,))
    except psycopg2.Error as e:
        print("Error deleting document:", e)

def updateDocument(cur, docId, docText, docTitle, docDate, docCat):
    try:
        deleteDocument(cur, docId)
        createDocument(cur, docId, docText, docTitle, docDate, docCat)
    except psycopg2.Error as e:
        print("Error updating document:", e)

def getIndex(cur):
    try:
        index = {}
        cur.execute("SELECT term, term_count FROM Document_Terms;")
        rows = cur.fetchall()

        for row in rows:
            term = row[0]
            term_count = row[1]

            if term not in index:
                index[term] = term_count
            else:
                index[term] += term_count

        return index
    except psycopg2.Error as e:
        print("Error fetching index:", e)
        return {}
