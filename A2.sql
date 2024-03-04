-- Create Categories table
CREATE TABLE Categories (
    id_cat SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Create Documents table
CREATE TABLE Documents (
    doc_id SERIAL PRIMARY KEY,
    text TEXT NOT NULL,
    title VARCHAR(255) NOT NULL,
    num_chars INT NOT NULL,
    doc_date DATE NOT NULL,
    id_cat INT NOT NULL,
    FOREIGN KEY (id_cat) REFERENCES Categories(id_cat)
);


-- Create Document_Terms table
CREATE TABLE Document_Terms (
    doc_id INT NOT NULL,
    term VARCHAR(255) NOT NULL,
    num_chars INT NOT NULL, -- Number of characters in the term
    term_count INT NOT NULL, -- How many times the term appears in the document
    PRIMARY KEY (doc_id, term),
    FOREIGN KEY (doc_id) REFERENCES Documents(doc_id)
);
CREATE TABLE IF NOT EXISTS Terms (
    id SERIAL PRIMARY KEY,
    term VARCHAR(255) UNIQUE
);


INSERT INTO Documents (doc_id, text, title, num_chars, doc_date, id_cat) VALUES
(1,'Baseball is played during summer months.', 'Exercise', 34, '2023-10-03', 1),
(2,'Summer is the time for picnics here. Picnics time!', 'California', 40, '2023-10-03', 1),
(3,'Months, months, months later we found out why', 'Discovery', 36, '2023-10-03', 2),
(4,'Why is summer so hot here? So hot!', 'Arizona', 25, '2023-10-03', 2);

INSERT INTO Categories (name) VALUES ('Sports'), ('Seasons');

INSERT INTO Document_Terms (doc_id, term, term_count, num_chars) VALUES
(1, 'baseball', 1, 8),
(1, 'is', 1, 2),
(1, 'played', 1, 6),
(1, 'during', 1, 6),
(1, 'summer', 1, 6),
(1, 'months', 1, 6),

(2, 'summer', 1, 6),
(2, 'is', 1, 2),
(2, 'the', 1, 3),
(2, 'time', 2, 4),
(2, 'for', 1, 3),
(2, 'picnics', 2, 7),
(2, 'here', 1, 4),

(3, 'months', 3, 6),
(3, 'later', 1, 5),
(3, 'we', 1, 2),
(3, 'found', 1, 5),
(3, 'out', 1, 3),
(3, 'why', 1, 3),

(4, 'why', 1, 3),
(4, 'is', 1, 2),
(4, 'summer', 1, 6),
(4, 'so', 2, 2),
(4, 'hot', 2, 3),
(4, 'here', 1, 4);

SELECT * FROM Categories; -- A
SELECT * FROM Documents;
SELECT * FROM Terms;
SELECT * FROM Document_Terms;

SELECT text, title --B
FROM Documents
JOIN Categories ON Documents.id_cat = Categories.id_cat
WHERE Categories.name = 'Sports';

SELECT DISTINCT term --C
FROM Document_Terms
WHERE term IN ('baseball', 'is', 'played', 'during', 'summer', 'months', 'the', 'time', 'for', 'picnics', 'here', 'later', 'we', 'found', 'out', 'why', 'so', 'hot');

SELECT SUM(term_count) --D
FROM Document_Terms
JOIN Documents ON Document_Terms.doc_id = Documents.doc_id
WHERE Documents.title = 'Arizona';

SELECT SUM(term_count) --E
FROM Document_Terms
JOIN Documents ON Document_Terms.doc_id = Documents.doc_id
JOIN Categories ON Documents.id_cat = Categories.id_cat
WHERE Categories.name = 'Seasons';

SELECT SUM(term_count) --F
FROM Document_Terms
WHERE term = 'months';

SELECT title, SUM(term_count) as total_terms --G
FROM Document_Terms
JOIN Documents ON Document_Terms.doc_id = Documents.doc_id
GROUP BY Documents.doc_id, title
ORDER BY total_terms DESC
LIMIT 1;

SELECT term, COUNT(DISTINCT Documents.doc_id) as doc_count
FROM Document_Terms
JOIN Documents ON Document_Terms.doc_id = Documents.doc_id
GROUP BY term
ORDER BY doc_count DESC, term
LIMIT 1;
