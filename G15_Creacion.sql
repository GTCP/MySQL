-- Table: Categoria
CREATE TABLE GR15_Categoria (
    id_Categoria int  NOT NULL,
    nombre_Categoria varchar(150)  NOT NULL,
    CONSTRAINT PK_GR15_Categoria PRIMARY KEY (id_Categoria)
);

-- Table: Distrito
CREATE TABLE GR15_Distrito (
    id_Distrito int  NOT NULL,
    nombre_Pais varchar(120)  NOT NULL,
    nombre_Provincia varchar(120)  NOT NULL,
    nombre_Distrito varchar(120)  NOT NULL,
    CONSTRAINT PK_GR15_Distrito PRIMARY KEY (id_Distrito)
);

-- Table: Evento
CREATE TABLE GR15_Evento (
    id_Evento int  NOT NULL,
    nombre_Evento varchar(250)  NOT NULL,
    descripcion_Evento text  NOT NULL,
    id_Categoria int  NOT NULL,
    id_SubCategoria int  NOT NULL,
    id_Usuario int  NOT NULL,
    id_Distrito int  NULL,
    dia_Evento int  NOT NULL,
    mes_Evento int  NOT NULL,
    repetir boolean  NOT NULL,
    CONSTRAINT PK_GR15_Evento PRIMARY KEY (id_Evento)
);

-- Table: Evento_Edicion
CREATE TABLE GR15_Evento_Edicion (
    id_Evento int  NOT NULL,
    nro_Edicion int  NOT NULL,
    fecha_inicio_pub date  NOT NULL,
    fecha_fin_pub date  NULL,
    presupuesto numeric(8,2)  NOT NULL,
    fecha_Edicion date  NULL,
    CONSTRAINT PK_GR15_Evento_Edicion PRIMARY KEY (id_Evento,nro_Edicion)
);

-- Table: Pais
CREATE TABLE GR15_Pais (
    nombre_Pais varchar(120)  NOT NULL,
    CONSTRAINT PK_GR15_Pais PRIMARY KEY (nombre_Pais)
);

-- Table: Patrocinante
CREATE TABLE GR15_Patrocinante (
    id_patrocinate int  NOT NULL,
    razon_social varchar(60)  NOT NULL,
    nombre_responsable varchar(60)  NOT NULL,
    apellido_responsable varchar(60)  NOT NULL,
    direccion varchar(200)  NULL,
    id_Distrito int  NOT NULL,
    CONSTRAINT PK_GR15_Patrocinante PRIMARY KEY (id_patrocinate)
);

-- Table: PATROCINIOS
CREATE TABLE GR15_Patrocinios (
    id_patrocinate int  NOT NULL,
    id_Evento int  NOT NULL,
    nro_Edicion int  NOT NULL,
    aporte numeric(8,2)  NOT NULL,
    CONSTRAINT PK_GR15_Patrocinios PRIMARY KEY (id_patrocinate,id_Evento,nro_Edicion)
);

-- Table: Provincia
CREATE TABLE GR15_Provincia (
    nombre_Pais varchar(120)  NOT NULL,
    nombre_Provincia varchar(120)  NOT NULL,
    CONSTRAINT PK_GR15_Provincia PRIMARY KEY (nombre_Pais,nombre_Provincia)
);

-- Table: SubCategoria
CREATE TABLE GR15_SubCategoria (
    id_Categoria int  NOT NULL,
    id_SubCategoria int  NOT NULL,
    nombre_SubCategoria varchar(150)  NOT NULL,
    CONSTRAINT PK_GR15_SubCategoria PRIMARY KEY (id_Categoria,id_SubCategoria)
);

-- Table: Usuario
CREATE TABLE GR15_Usuario (
    id_Usuario int  NOT NULL,
    nombre varchar(40)  NOT NULL,
    apellido varchar(40)  NOT NULL,
    e_mail varchar(320)  NOT NULL,
    password varchar(32)  NOT NULL,
    CONSTRAINT PK_GR15_Usuario PRIMARY KEY (id_Usuario)
);

-- foreign keys
-- Reference: FK_GR15_Distrito_Provincia (table: GR15_Distrito)
ALTER TABLE GR15_Distrito ADD CONSTRAINT FK_GR15_Distrito_Provincia
    FOREIGN KEY (nombre_Pais, nombre_Provincia)
    REFERENCES GR15_Provincia (nombre_Pais, nombre_Provincia)  
;

-- Reference: FK_Evento_Distrito (table: Evento)
ALTER TABLE GR15_Evento ADD CONSTRAINT FK_GR15_Evento_Distrito
    FOREIGN KEY (id_Distrito)
    REFERENCES GR15_Distrito (id_Distrito)  
;

-- Reference: FK_Evento_Edicion_Evento (table: Evento_Edicion)
ALTER TABLE GR15_Evento_Edicion ADD CONSTRAINT FK_GR15_Evento_Edicion_Evento
    FOREIGN KEY (id_Evento)
    REFERENCES GR15_Evento (id_Evento)  
;

-- Reference: FK_Evento_SubCategoria (table: Evento)
ALTER TABLE GR15_Evento ADD CONSTRAINT FK_GR15_Evento_SubCategoria
    FOREIGN KEY (id_Categoria, id_SubCategoria)
    REFERENCES GR15_SubCategoria (id_Categoria, id_SubCategoria)  
;

-- Reference: FK_Evento_Usuario (table: Evento)
ALTER TABLE GR15_Evento ADD CONSTRAINT FK_GR15_Evento_Usuario
    FOREIGN KEY (id_Usuario)
    REFERENCES GR15_Usuario (id_Usuario)  
;

-- Reference: FK_Patrocinios_Evento_Edicion (table: PATROCINIOS)
ALTER TABLE GR15_Patrocinios ADD CONSTRAINT FK_GR15_Patrocinios_Evento_Edicion
    FOREIGN KEY (id_Evento, nro_Edicion)
    REFERENCES GR15_Evento_Edicion (id_Evento, nro_Edicion)  
;

-- Reference: FK_Patrocinios_Patrocinante (table: PATROCINIOS)
ALTER TABLE GR15_Patrocinios ADD CONSTRAINT FK_GR15_Patrocinios_Patrocinante
    FOREIGN KEY (id_patrocinate)
    REFERENCES GR15_Patrocinante (id_patrocinate)  
;

-- Reference: FK_Provincia_Pais (table: Provincia)
ALTER TABLE GR15_Provincia ADD CONSTRAINT FK_GR15_Provincia_Pais
    FOREIGN KEY (nombre_Pais)
    REFERENCES GR15_Pais (nombre_Pais)  
;

-- Reference: FK_SubCategoria_Categoria (table: SubCategoria)
ALTER TABLE GR15_SubCategoria ADD CONSTRAINT FK_GR15_SubCategoria_Categoria
    FOREIGN KEY (id_Categoria)
    REFERENCES GR15_Categoria (id_Categoria)  
;

-- Reference: FK_Patrocinante_Distrito (table: Patrocinante)
ALTER TABLE GR15_Patrocinante ADD CONSTRAINT FK_GR15_Patrocinante_Distrito
    FOREIGN KEY (id_Distrito)
    REFERENCES GR15_Distrito (id_Distrito)  
;

-- End of file.