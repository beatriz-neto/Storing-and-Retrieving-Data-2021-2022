-- -----------------------------------------------------
-- DATABASE tb
-- -----------------------------------------------------

-- DROP DATABASE `tb`;
CREATE DATABASE IF NOT EXISTS `tb` DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';

/*tell which database you will use*/
USE `tb` ;

-- NOTE: Almost all primary keys have VARCHAR type for better interpretation and organization in the database, especially in the insertion of Data.
-- -----------------------------------------------------
-- Table `tb`.`zone`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `zone` (
  `zone_id` VARCHAR(3) NOT NULL,
  `session_id` VARCHAR(4) NOT NULL,
  `zone_description` VARCHAR(100) NOT NULL,
  `ticket_unit_price` DECIMAL(5,2) NOT NULL, # monetary field has a decimal type once the data needs to be exact
  `event_space_id` VARCHAR(4) NOT NULL,    
  
  PRIMARY KEY (`zone_id`, `session_id`) # Composite key because the space where occurs is divided in zones which can vary depending on the session that willtake place in.
);

-- -----------------------------------------------------
-- Table `tb`.`ticket`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ticket` (	
  `bar_code` BIGINT NOT NULL , # Each ticket has an unique bar code
  `company_name` VARCHAR(11) DEFAULT 'TicketBuddy',
  `company_phonenumber` INT DEFAULT '707234234',
  `company_website` VARCHAR(200) DEFAULT 'www.ticketbuddy.pt',  
  `seat_id` VARCHAR(4) NOT NULL,
  `customer_id` VARCHAR(4) DEFAULT NULL,  
  
  PRIMARY KEY (`bar_code`)
);

-- -----------------------------------------------------
-- Table `tb`.`seat`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `seat` (
  `seat_id` VARCHAR(4) NOT NULL,
  `seat_code` VARCHAR(15) NOT NULL,
  `zone_id` VARCHAR(3) NOT NULL,
  
  PRIMARY KEY (`seat_id`)
);

-- -----------------------------------------------------
-- Table `tb`.`location`
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS `location` (
  `location_id` INT NOT NULL,
  `address` VARCHAR(100) NOT NULL,
  `zip_code` VARCHAR(8) NOT NULL,
  `city` VARCHAR(40) NOT NULL,
  `district` VARCHAR(60) NOT NULL,
  `continental_city` TINYINT NULL,
  `gps_lat` DECIMAL(17,15) NULL,
  `gps_long` DECIMAL(17,15) NULL,
  
  PRIMARY KEY (`location_id`)
);

-- NOTE: Similar to what we did in the classes we kept the city and district as attributes of the location instead of creating a new table for the city.

-- -----------------------------------------------------
-- Table `tb`.`costumer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `customer` (
	`customer_id` VARCHAR(4) NOT NULL, # Once the nif is an optional field we use customer_id as primary key
	`name` VARCHAR(45) NOT NULL,
	`email` VARCHAR(45) NOT NULL,
	`phonenumber` INT NOT NULL,
	`nif` INT DEFAULT 999999990,
    `location_id` INT NOT NULL,

	PRIMARY KEY (`customer_id`)
);

-- -----------------------------------------------------
-- Table `tb`.`promotor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `promotor` (
	`promotor_nif` INT NOT NULL, # because each promotor has a fiscal number that is unique
	`promotor_name` VARCHAR(80) NOT NULL,
	`promotor_email` VARCHAR(45) DEFAULT NULL,
	`promotor_website` VARCHAR(200) DEFAULT NULL,
	`promotor_phonenumber` INT DEFAULT NULL,
    `location_id` INT NOT NULL,
    
	PRIMARY KEY (`promotor_nif`)
);

-- -----------------------------------------------------
-- Table `tb`.`event_space`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `event_space` (
	`event_space_id` VARCHAR(4) NOT NULL,
	`name` VARCHAR(45) DEFAULT NULL,
	`space_type` VARCHAR(10) DEFAULT NULL, 
	`email` VARCHAR(45) DEFAULT NULL,
	`website` VARCHAR(200) DEFAULT NULL,
	`phonenumber` INT DEFAULT NULL,
    `location_id` INT NOT NULL,

	PRIMARY KEY (`event_space_id`)
);
-- -----------------------------------------------------
-- Table `tb`.`event`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `event` (
	`event_id` VARCHAR(3) NOT NULL,
	`event_description` VARCHAR(100) NOT NULL,
	`event_type` VARCHAR(20) NOT NULL, # We thought about storing the category of the event as an enum to garantee a higher performance of the query. 
									   # However the categroy had more than a few unique string values
	`start_date` DATE NOT NULL,
	`end_date` DATE DEFAULT NULL,
	`viewers_min_age` VARCHAR(20) NOT NULL,
    `promotor_nif` INT NOT NULL,
    `event_space_id` VARCHAR(4) NOT NULL,

	PRIMARY KEY (`event_id`)
);

-- -----------------------------------------------------
-- Table `tb`.`session`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `session` (
	`session_id` VARCHAR(4) NOT NULL,
	`session_date` DATE NOT NULL,
	`start_hour` TIME NOT NULL,
	`end_hour` TIME DEFAULT NULL,
	`time_of_day` VARCHAR(10) DEFAULT NULL,
	`week_day` VARCHAR(15) NOT NULL,
	`number_of_tickets_available` INT NOT NULL,	
    `event_id` VARCHAR(3) NOT NULL,

	PRIMARY KEY (`session_id`)
);

-- -----------------------------------------------------
-- Table `tb`.`rating`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `rating` (
  `rating_id` INT NOT NULL,
  `rating_datetime` DATETIME NOT NULL,
  `rating_value` INT NOT NULL,
  `comment` VARCHAR(300) NULL,
  `customer_id` VARCHAR(4) NOT NULL,
  `session_id` VARCHAR(4) NOT NULL,
  
  PRIMARY KEY (`rating_id`)
);

-- -----------------------------------------------------
-- Table `tb`.`promotion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `promotion` (
  `promotion_id` VARCHAR(3) NOT NULL,
  `promotion_code` VARCHAR(30) NULL,
  `promotion_description` VARCHAR(50) NULL,
  `start_date` DATE NULL,
  `end_date` DATE NULL,
  `promotion_rate` DECIMAL(2,2) NULL,
  
  PRIMARY KEY (`promotion_id`)
);

-- -----------------------------------------------------
-- Table `tb`.`order_`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `order_` (
	`order_id` VARCHAR(4) NOT NULL,
	`quantity` INT DEFAULT NULL,
	`total` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    `order_datetime` DATETIME NOT NULL,
    `tax_rate` DECIMAL(2,2) NOT NULL DEFAULT 0.00,
    `promotion_id` VARCHAR(3) DEFAULT 'P0',
    `customer_id` VARCHAR(4) NOT NULL,

	PRIMARY KEY (`order_id`)
);

-- NOTE: total and tax_rate are DEFAULT 0.00 because later they will be update.

-- -----------------------------------------------------
-- Table `tb`.`order_items`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `order_items` (
	`order_id` VARCHAR(4) NOT NULL,
	`bar_code` BIGINT NOT NULL,
	`insurance` DECIMAL(4,2) NOT NULL,
	
	PRIMARY KEY (`order_id`, `bar_code`) 
);

-- -----------------------------------------------------
-- Table `tb`.`card`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `card` (
	`card_number` BIGINT NOT NULL,
	`titular_name` VARCHAR(50) NOT NULL,
	`CVV` INT NOT NULL,	
	`date_expiration` VARCHAR(5) NOT NULL,	

	PRIMARY KEY (`card_number`)
);

-- NOTE: We created this table instead of using the card as the payment table attribute to ensure we are complying with 3NF.

-- -----------------------------------------------------
-- Table `tb`.`payment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `payment` (
	`order_id` VARCHAR(4) NOT NULL,
	`card_number` BIGINT NOT NULL,
	`payment_datetime` DATETIME NOT NULL,

	PRIMARY KEY (`order_id`, `card_number`)
);

-- -----------------------------------------------------
-- Table `tb`.`log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `log` (
  `id` INTEGER UNSIGNED AUTO_INCREMENT,
  `datetime_change` DATETIME NOT NULL,
  `old_date_session` DATE NOT NULL,
  `new_date_session` DATE NOT NULL,
  `session_id` VARCHAR(4) NOT NULL,  
  `user` VARCHAR(100) NOT NULL,
  
  PRIMARY KEY (`id`)
);

-- NOTE: We decided to create the log table along with the others. The business process associated with it is the change of the dates of the sessions.

-- -----------------------------------------------------
-- Defining FK's and checks
-- -----------------------------------------------------
ALTER TABLE `promotor`
ADD CONSTRAINT `promotor_nif_check`
	CHECK(promotor_nif > 0),
ADD CONSTRAINT `promotor_email_unique`
	UNIQUE(promotor_email),
ADD CONSTRAINT `promotor_website_unique`
	UNIQUE(promotor_website),
ADD CONSTRAINT `fk_promotor_location`
	FOREIGN KEY (`location_id`)
	REFERENCES `location` (`location_id`)
	ON DELETE RESTRICT       # can't delete a location that have a promotor associated to it
    ON UPDATE CASCADE;       # if the location is updated so will be the promotor
  
ALTER TABLE `event_space`
ADD CONSTRAINT `event_space_email_unique`
	UNIQUE(email),
ADD CONSTRAINT `event_space_website_unique`
	UNIQUE(website),
ADD CONSTRAINT `event_space_phonenumber_unique`
	UNIQUE(phonenumber),
ADD CONSTRAINT `fk_event_space_location`
	FOREIGN KEY (`location_id`)
	REFERENCES `location` (`location_id`)
	ON DELETE RESTRICT      # can't delete a location that have an event space associated to it
	ON UPDATE CASCADE;      # if the location is updated so will be the event space

ALTER TABLE `event` 
ADD CONSTRAINT `fk_event_promotor`
	FOREIGN KEY (`promotor_nif`)
	REFERENCES `promotor` (`promotor_nif`)
	ON DELETE CASCADE      # if the promotor is deleted so will be the event
	ON UPDATE RESTRICT,    # can't update a promotor nif that have an event associated to it
ADD CONSTRAINT `fk_event_event_space`
	FOREIGN KEY (`event_space_id`)
	REFERENCES `event_space` (`event_space_id`)
	ON DELETE CASCADE      # if the event space is deleted so will be the event
	ON UPDATE CASCADE;     # if the event space is updated so will be the event

ALTER TABLE `session`
ADD CONSTRAINT `fk_session_event`
	FOREIGN KEY (`event_id`)
	REFERENCES `event` (`event_id`)
	ON DELETE CASCADE      # if the event is deleted so will be the session
	ON UPDATE CASCADE;     # if the event is updated so will be the session
  
ALTER TABLE `customer`
ADD CONSTRAINT `fk_customer_location`
  FOREIGN KEY (`location_id`)
  REFERENCES `location` (`location_id`)
  ON DELETE RESTRICT      # can't delete a location that have a customer associated to it
  ON UPDATE CASCADE;      # if the location is updated so will be the customer
  
ALTER TABLE `rating`
ADD CONSTRAINT `rating_value_check`
	CHECK ((rating_value >= 1) AND (rating_value <= 5)),   # rating needs to be between 1 and 5
ADD CONSTRAINT `fk_rating_customer`
	FOREIGN KEY (`customer_id`)
	REFERENCES `customer` (`customer_id`)
	ON DELETE RESTRICT    # can't delete a customer that have a rating associated to it
	ON UPDATE RESTRICT,   # can't update a customer id that have an rating associated to it
ADD CONSTRAINT `fk_rating_session`
	FOREIGN KEY (`session_id`)
	REFERENCES `session` (`session_id`)
	ON DELETE RESTRICT    # can't delete a session that have a rating associated to it
	ON UPDATE RESTRICT;   # can't update a session id that have an rating associated to it
  
ALTER TABLE `zone`
ADD CONSTRAINT `fk_zone_event_space`
	FOREIGN KEY (`event_space_id`)
	REFERENCES `event_space` (`event_space_id`)
	ON DELETE RESTRICT    # can't delete a event space that have a zone associated to it
	ON UPDATE CASCADE,    # if the event space is updated so will the zone
ADD CONSTRAINT `fk_zone_session`
	FOREIGN KEY (`session_id`)
	REFERENCES `session` (`session_id`)
    ON DELETE CASCADE     # if the session is deleted so will be the zone
	ON UPDATE CASCADE;    # if the session is updated so will be the zone

ALTER TABLE `seat`
ADD CONSTRAINT `fk_seat_zone`
	FOREIGN KEY (`zone_id`)
	REFERENCES `zone` (`zone_id`)
	ON DELETE CASCADE    # if the zone is deleted so will be the seat
	ON UPDATE CASCADE;   # if the zone is updated so will be the seat

ALTER TABLE `order_`
ADD CONSTRAINT `fk_order_promotion`
	FOREIGN KEY (`promotion_id`)
	REFERENCES `promotion` (`promotion_id`)
	ON DELETE RESTRICT   # can't delete a promotion that have a order_ associated to it
	ON UPDATE CASCADE,   # if the promotion is updated so will be the order_
ADD CONSTRAINT `fk_order_customer`
	FOREIGN KEY (`customer_id`)
	REFERENCES `customer` (`customer_id`)
	ON DELETE CASCADE    # if the customer is deleted so will be the order_
	ON UPDATE RESTRICT;  # can't update a customer id that have an order_ associated to it
  
ALTER TABLE `order_items`
ADD CONSTRAINT `order_items_insurance_check`
	CHECK ((insurance = 0.00) OR (insurance = 1.20)),  # is 0.00 when the customer don't make insurance, 1.20 otherwise
ADD CONSTRAINT `fk_order_items_order`
	FOREIGN KEY (`order_id`)
	REFERENCES `order_` (`order_id`),
ADD CONSTRAINT `fk_order_items_ticket`
	FOREIGN KEY (`bar_code`)
	REFERENCES `ticket` (`bar_code`)
	ON DELETE CASCADE;   # if the ticket is deleted so will be the order_items
  
ALTER TABLE `payment`
ADD CONSTRAINT `fk_payment_order`
	FOREIGN KEY (`order_id`)
	REFERENCES `order_` (`order_id`)
	ON DELETE RESTRICT,
ADD CONSTRAINT `fk_payment_card`
	FOREIGN KEY (`card_number`)
	REFERENCES `card` (`card_number`)
	ON DELETE CASCADE;   # if the card is deleted so will be the payment
  
ALTER TABLE `ticket`
ADD CONSTRAINT `fk_ticket_seat`
	FOREIGN KEY (`seat_id`)
	REFERENCES `seat` (`seat_id`)
	ON DELETE CASCADE,   # if the seat is deleted so will be the ticket
ADD CONSTRAINT `fk_ticket_customer`
	FOREIGN KEY (`customer_id`)
	REFERENCES `customer` (`customer_id`)
	ON UPDATE RESTRICT;  #  can't update a customer id that have an ticket associated to it
      
-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------

-- Trigger 1 : Inserts a row in a ???log??? table when a session is postponed. Store the old and new date of the session

DROP TRIGGER IF EXISTS `Update_session_date`;
DELIMITER $$
CREATE TRIGGER `Update_session_date` AFTER UPDATE ON `session` FOR EACH ROW 
BEGIN
	INSERT INTO log(datetime_change, old_date_session, new_date_session, session_id, user) 
	VALUES (now(), OLD.session_date, NEW.session_date, NEW.session_id, user());
END
$$
DELIMITER ;

-- Trigger 2: After insert all the tickets associated in the order, upadates the quantity on the order

DROP TRIGGER IF EXISTS `Order_Quantity_Update`;
DELIMITER $$
CREATE TRIGGER `Order_Quantity_Update` AFTER INSERT ON `order_items` FOR EACH ROW 
BEGIN
	UPDATE order_ AS o
    INNER JOIN (SELECT o.order_id AS id_order, COUNT(oi.order_id) AS quantity 
				FROM order_ AS o 
                LEFT JOIN order_items AS oi ON o.order_id = oi.order_id
				GROUP BY o.order_id) AS count_number_of_tickets_ordered_table
		ON o.order_id = count_number_of_tickets_ordered_table.id_order                
	SET o.quantity = count_number_of_tickets_ordered_table.quantity ;
END
$$
DELIMITER ;

-- Trigger 3 : Once the payment is made the ticket is customized in order to have the clients' information.

DROP TRIGGER IF EXISTS `Info_Customer_Update`;
DELIMITER $$
CREATE TRIGGER `Info_Customer_Update` AFTER INSERT ON `payment` FOR EACH ROW 
BEGIN
	UPDATE ticket AS t
	SET t.customer_id = (SELECT o.customer_id
						 FROM payment AS p, order_ AS o, order_items AS o_i
                         WHERE p.order_id = o.order_id 
                         AND o.order_id = o_i.order_id
                         AND o_i.bar_code = t.bar_code
						);
END
$$
DELIMITER ;

-- -----------------------------------------------------
-- Insert Data 
-- -----------------------------------------------------

INSERT INTO `location` (`location_id`, `address`, `zip_code`, `city`, `district`, `continental_city`, `gps_lat`, `gps_long`) VALUES
(1, 'R. Vale dos Dinossauros 25', '2530-059', 'Lisboa', 'Lisboa',  1, 39.278526, -9.293103),
(2, 'Travessa da Gal??, 36', '1349-028','Lisboa', 'Lisboa', 1, 38.7167, -9.1333),
(3, 'R. Eng. Paulo Barros 12A', '1500-264','Lisboa','Lisboa', 1, 38.747417, -9.206836),
(4, 'R. Manuel Soares Guedes 13A', '1170-206','Lisboa','Lisboa', 1, 38.719932, -9.133925437927246),
(5, 'Rua de Xabregas 54', '1900-400', 'Lisboa','Lisboa', 1, 38.726581, -9.111506),
(6, 'Tv. Paulo Jorge', '1300-598', 'Lisboa', 'Lisboa', 1, 38.697750, -9.194580),
(7, 'Rua Rodrigues De Faria Nr.103 Edif. G6', '1300-501','Lisboa','Lisboa', 1, 38.7041413, -9.1775532),
(8, 'Av. da Rep??blica 6 1?? Esq', '1050-191' , 'Lisboa','Lisboa', 1, 38.7370683, -9.145720),
(9, 'R. Prof. Reinaldo dos Santos 12 D', '1549-006','Lisboa','Lisboa', 1, 38.761267, -9.178316),
(10, 'JARDINS DO BUZANO LOTE 166 LOJA B', '2785-717', 'Lisboa','Lisboa', 1, 38.70123, -9.3276),
(11, 'R FLORBELA ESPANCA 46', '2775-091','Lisboa', 'Lisboa', 1, 38.69282, -9.35412),
(12, 'Av. da Liberdade 182 A', '1250-096', 'Lisboa','Lisboa',1, 38.720108, -9.144993),
(13, 'Pra??a da Rep??blica Apartado 244', '3810-156', 'Aveiro', 'Aveiro', 1, 40.678384,-8.556855),
(14, 'EST DA LUZ', '1600-153', 'Lisboa', 'Lisboa', 1, 38.749061, -9.172051),
(15, 'Largo Pimenteiras 6', '1600-576' , 'Lisboa', 'Lisboa', 1, 38.759931, -9.185739),
(16, 'Pra??a do Imp??rio', '1449-003', 'Lisboa', 'Lisboa', 1, 38.696006, -9.20596981048584),
(17, 'Rua P??ro da Covilh?? 36', '1400-296' , 'Lisboa', 'Lisboa', 1, 38.702232360839844, -9.212331771850586),
(18, 'Tv. Dores 19B', '1300-415', 'Lisboa', 'Lisboa', 1, 38.7027587890625, -9.19267463684082),
(19, 'Rua Bulh??o Pato N??1B', '1700-081', 'Lisboa', 'Lisboa', 1, 38.7612672, -9.1783168),
(20, 'Rua N.?? 2 N.?? 221', '4480-068', 'Porto','Porto', 1, 41.33922, -8.71806),
(21, 'R. Castilho 39 13?? C', '1250-068', 'Lisboa','Lisboa', 1, 38.7229615, -9.151968),
(22, 'Edif??cio da Reitoria, Alameda da Universidade','1649-004','Lisboa','Lisboa', 1, 38.7547009, -9.1519637),
(23, 'R. de S?? da Bandeira 108', '4000-427','Porto','Porto', 1, 41.14657974243164, -8.608723640441895),
(24, 'Cais da Fonte Nova', '3810-164','Aveiro','Aveiro', 1, 40.64226150512695, -8.649789810180664),
(25, 'Av. Fontes Pereira de Melo 30A', '1050-122','Lisboa','Lisboa', 1, 38.73026657104492, -9.146937370300293),
(26, 'Av. da ??ndia 136', '1300-300', 'Lisboa','Lisboa', 1, 38.694454193115234, -9.208612442016602),
(27, 'Av. Mar. Gomes da Costa 13 A', '1800-999', 'Lisboa','Lisboa', 1, 38.716671, -9.133331),
(28, 'Rossio dos Olivais', '1990-231', 'Lisboa','Lisboa', 1, 38.76710891723633, -9.092469215393066),
(29, 'Campo Pequeno', '1000-082', 'Lisboa','Lisboa',  1, 38.7429278, -9.146824),
(30, 'Jardins do Pal??cio de Cristal, R. de Dom Manuel II', '4050-346','Porto','Porto', 1, 41.1470671, -8.6262614),
(31, 'Av. Dr. Stanley Ho', '2765-190', 'Lisboa', 'Lisboa',  1, 38.708003997802734, -9.397119522094727),
(32, 'R. de Passos Manuel 137', '4000-385', 'Porto','Porto', 1, 41.146732330322266, -8.605484962463379),
(33, 'R. Bel??m do Par??', '3810-009','Aveiro','Aveiro', 1, 40.640811920166016, -8.65457820892334),
(34, 'Av. Frei Miguel Contreiras 52', '1700-213', 'Lisboa','Lisboa', 1, 38.74584197998047, -9.138879776000977),
(35, 'Av. Escola dos Fuzileiros Navais 53A', '2830-149','Barreiro', 'Set??bal', 1, 38.640689849853516, -9.056632041931152),
(36, 'Estrada da Pontinha 7', '1600-583', 'Lisboa','Lisboa', 1, 38.76118087768555, -9.192147254943848),
(37, 'R. Alm. Barroso 25A', '1000-012', 'Lisboa','Lisboa', 1, 38.731117248535156, -9.143129348754883),
(38, 'Av. Gomes Pereira 17', '1549-019', 'Lisboa','Lisboa', 1, 38.7487168, -9.1974407),
(39, 'Rua Figueira Grande, lote 3, 2??G', '2910-494','Set??bal','Set??bal', 1, NULL, NULL),
(40, 'Rua Homem Cristo Filho, n??2', '3810-164', 'Aveiro','Aveiro', 1, NULL, NULL),
(41, 'Rua da Carreira de Tiro, n??18, 2??B', '6000-367', 'Castelo Branco','Castelo Branco', 1, 39.810845, -7.503793),
(42, 'Rua Manuel Ferreira de Andrade, n??20, 3??Direito', '1500-101', 'Lisboa','Lisboa', 1, NULL, NULL),
(43, 'Rua de Ribeiro de Sousa, n??45, 1??Frente', '4250-168','Porto','Porto', 1, 41.163679, -8.615161),
(44, 'Avenida Jos?? dos Santos Farias, n??3, 2??Esquerdo', '8135-016', 'Almancil', 'Faro', 1, NULL, NULL),
(45, 'Rua Capit??o Jos?? Pacheco, n??8, 2??Direito', '2910-573', 'Set??bal','Set??bal', 1, NULL, NULL),
(46, 'Rua Carlos Alberto Correia Ribeiro, n??20, 1??Direito', '8400-414', 'Lagoa','Faro', 1, NULL, NULL),
(47, 'Rua Pero de Alenquer, n??6, 7??A', '7520-177', 'Sines','Set??bal', 1, 37.955912, -8.868293),
(48, 'Rua Eira, n??47', '3030-194', 'Coimbra', 'Coimbra', 1, 40.185833, -8.407509),
(49, 'Rua Daciano Costa, n??30, 4??B', '1600-038', 'Lisboa','Lisboa', 1, 38.776746, -9.172221),
(50, 'Largo 2 de Mar??o, n??2', '9500-089', 'Ponta Delgada', 'Regi??o Aut??noma dos A??ores', 0, NULL, NULL),
(51, 'Rua da Cal??ada, n??6', '9125-065', 'Cani??o', 'Regi??o Aut??noma da Madeira', 0, 32.648307, -16.842288),
(52, 'Rua dos Almeida Furtado, lote 229', '3500-401', 'Viseu', 'Viseu', 1, NULL, NULL),
(53, 'Rua da Ancha, n??1, 1??Esquerdo', '7800-036', 'Beja','Beja', 1, NULL, NULL),
(54, 'Rua da Azinheira, n??211, 3??J', '7570-789', 'Tr??ia', 'Set??bal', 1, 38.492672, -8.901799),
(55, 'Avenida Cidade de Zamoura, n??12, 1??Frente', '5300-111','Bragan??a','Bragan??a', 1, NULL, NULL),
(56, 'Rua Rep??blica, n??17, 1??Direito', '7000-854', '??vora','??vora', 1, 38.570397, -7.908776),
(57, 'Rua do Raio, n??49, 4??C', '4700-924', 'Braga', 'Braga', 1, 41.548801, -8.421891),
(58, 'Rua Doutor Jo??o de Paiva, n??5', '7630-139', 'Odemira', 'Beja', 1, NULL, NULL),
(59, 'Avenida 25 de Abril, n??33, 3??Esquerdo', '3810-164', 'Aveiro','Aveiro', 1, 40.638607, -8.649967),
(60, 'Rua da Saboaria, n??21', '2950-274', 'Palmela','Set??bal', 1, 38.567819, -8.900901),
(61, 'Rua Almeida Gago Coutinho, n??21, 2??D', '2560-303', 'Torres Vedras','Lisboa', 1, NULL, NULL),
(62, 'Avenida do Forte, n??46, 6??E', '2790-072', 'Carnaxide','Lisboa', 1, 38.722427, -9.234873),
(63, 'Rua Rainha Dona Catarina, n??71, 4??Frente', '1500-537', 'Lisboa','Lisboa', 1, NULL, NULL),
(64, 'Avenida da Igreja, n??60, 5??B', '1700-240', 'Lisboa','Lisboa', 1, NULL, NULL),
(65, 'Rua Gondivai, n??579, 4??A', '4465-651', 'Le??a do Balio', 'Porto',  1, NULL, NULL),
(66, 'Rua J??lio Dantas, n??30, 6??Frente', '4470-098', 'Maia','Porto', 1, NULL, NULL),
(67, 'Rua J??lio Dantas, n??32, 3??Esquerdo', '4470-098', 'Maia','Porto', 1, NULL, NULL),
(68, 'Avenida da Igreja, n??62, 1??C', '1700-240', 'Lisboa','Lisboa', 1, NULL, NULL),
(69, 'Largo 2 de Mar??o, n??5', '9500-089', 'Ponta Delgada','Regi??o Aut??noma dos A??ores', 0, NULL, NULL),
(70, 'Rua da Pedra, n??28, 3??C', '8500-792', 'Portim??o','Faro',  1, 37.1466106, -8.557315),
(71, 'Rua Castilho, n??21, 2??B', '8000-245', 'Faro','Faro', 1, 37.015479, -7.932508),
(72, 'Rua Castilho, n??16, 4??D', '8000-245', 'Faro','Faro', 1, NULL, NULL),
(73, 'Avenida Doutor Manuel de Arriaga, n??15, 2??Esquerdo', '2900-473', 'Set??bal','Set??bal', 1, NULL, NULL),
(75, 'Travessa do Teatro, n??8, 2??Direito', '7300-126', 'Portalegre','Portalegre', 1, 39.294237, -7.429746),
(76, 'Rua Lu??sa Grande, n??12, 2??A', '7300-126', 'Portalegre','Portalegre', 1, NULL, NULL),
(77, 'Rua Capit??o M??rio Alberto Soares Pimentel, n??12, 1??Direito','2710-589', 'Sintra','Lisboa', 1, NULL, NULL),
(78, 'Rua Capit??o M??rio Alberto Soares Pimentel, n??14, 2??Esquerdo','2710-589', 'Sintra','Lisboa',1, NULL, NULL),
(79, 'Rua Ulysses Alves, n??13, 2??A', '2710-605', 'Sintra','Lisboa', 1, 38.802775, -9.380556),
(80, 'Rua Actor Jos?? Ricardo, n??2', '2710-583', 'Sintra','Lisboa', 1, NULL, NULL),
(81, 'Rua Maria Alda Barbosa Nogueira, lote 40, 6??Frente', '2700-511', 'Amadora','Lisboa', 1, 38.756036, -9.225506),
(82, 'Rua Vicente Esteves, lote 2, 2??G', '2700-307', 'Amadora','Lisboa', 1, NULL, NULL),
(83, 'Praceta Serrado da Bica, n??37, 4??B', '2700-416', 'Amadora','Lisboa', 1, NULL, NULL),
(84, 'Rua Salvador Vilhena, n??23', '7520-437', 'Porto Covo','Set??bal', 1 , NULL, NULL),
(85, 'Rua da Vilarinha, lote 3, 3??C', '4100-332','Porto','Porto', 1, NULL, NULL),
(86, 'Rua da Vilarinha, lote 7, 5??A', '4100-332', 'Porto','Porto', 1, NULL, NULL),
(87, 'Rua Primeiro de Maio, n??10, 3??A', '8600-754', 'Lagos','Faro', 1, NULL, NULL),
(88, 'Travessa do Pa??o, n??3', '8600-752', 'Lagos', 'Faro', 1, 37.100716, -8.674141),
(89, 'Rua Elias Garcia, n??2, 3??A', '8400-384', 'Lagoa','Faro', 1, NULL, NULL),
(90, 'Rua Tenheira Valadim, n??14, 4??B', '4900-356', 'Viana do Castelo','Viana do Castelo', 1, NULL, NULL),
(91, 'Rua de Altamira, n??22, 3??H', '4900-334', 'Viana do Catelo','Viana do Castelo',1, 41.691130, -8.831586),
(92, 'Rua Doutor Francisco Meira, n??2, 3??Frente', '2005-170', 'Santar??m','Santar??m',1, 39.234459, -8.699711),
(93, 'Avenida Marqu??s de Pombal, n??68, 2??R', '2005-170', 'Santar??m', 'Santar??m', 1, NULL, NULL),
(94, 'Avenida 25 de Abril, n??26, 2??A', '7160-221', 'Vila Vi??osa','??vora',1, NULL, NULL),
(95, 'Rua Augusta, n??26, Resto-ch??o', '7160-050', 'Vila Vi??osa','??vora',1, 38.773642, -7.416207),
(96, 'Rua Duarte Pacheco, n??3', '2975-306', 'Quinta do Conde','Set??bal',1, NULL, NULL),
(97, 'Rua da Quinta de Santa Maria, n??42, 9??C', '1800-280', 'Lisboa','Lisboa',  1, 38.777290, -9.120479),
(98, 'Rua da Arroja, n??12, 4??D', '2675-545', 'Odivelas','Lisboa', 1, NULL, NULL),
(99, 'Rua da Arroja, n??6, 6??E', '2675-545', 'Odivelas','Lisboa', 1, NULL, NULL),
(100, 'Rua Guilhermina Suggia, n??10', '2670-376', 'Loures','Lisboa', 1, 38.831492, -9.173909),
(101, 'Rua S??o Pedro, n??4, 1??B', '3000-370', 'Coimbra', 'Coimbra', 1, NULL, NULL),
(102, 'Rua Jos?? Falc??o, n??15, 2??Esquerdo', '3000-233', 'Coimbra', 'Coimbra', 1, NULL, NULL),
(103, 'Rua Jos?? Augusto Coelho, n??8', '2925-538', 'Azeit??o','Set??bal', 1,  NULL, NULL),
(104, 'Rua Col??gio Academia Figueirense,  n??333, 5??J', '3080-140', 'Figueira da Foz','Coimbra', 1, NULL, NULL),
(105, 'Rua do Hospital, n??75, 8??A', '3080-124', 'Figueira da Foz','Coimbra', 1, 40.152198, -8.856409),
(106, 'Rua do Hospital, n??60, 4??Direito', '3080-124', 'Figueira da Foz', 'Coimbra',1, NULL, NULL),
(107, 'Rua Margarida de Chaves, n??119, 1??Direito', '9500-075', 'Ponta Delgada','Regi??o Aut??noma dos A??ores',0, NULL, NULL),
(108, 'Rua de ??gua, n??49, Resto-ch??o', '9500-040', 'Ponta Delgada','Regi??o Aut??noma dos A??ores', 0, NULL, NULL),
(109, 'Rua Conselheiro Medeiros, n??14, 1??Frente', '9900-123', 'Horta','Regi??o Aut??noma dos A??ores', 0, NULL, NULL),
(110, 'Rua Major Har??cio Saloio, n??4, 1??Direito','9900-016', 'Horta', 'Regi??o Aut??noma dos A??ores', 0, NULL, NULL),
(111, 'Avenida Avelino Texeira da Mota, n??309, 6??B', '1950-037', 'Lisboa','Lisboa', 1, NULL, NULL),
(112, 'Avenida Avelino Texeira da Mota, n??234, 7??C', '1950-037', 'Lisboa','Lisboa', 1, NULL, NULL),
(113, 'Travessa do Prior, n??70, 3??C', '2750-748', 'Cascais','Lisboa', 1, NULL, NULL),
(114, 'Avenida Vasco da Gama, n??322, 7??Esquerdo', '2750-642', 'Cascais', 'Lisboa', 1, NULL, NULL),
(115, 'Rua Jo??o Teixeira Sim??es, n??6, 1??A', '2780-293', 'Oeiras','Lisboa', 1, NULL, NULL),
(116, 'Rua Gil Eanes, n??33, 2??Frente', '8200-188', 'Albufeira','Faro', 1, NULL, NULL),
(117, 'Rua Sacadura Cabral, n??76, 1??B', '8200-179', 'Albufeira','Faro', 1, NULL, NULL),
(118, 'Rua Sacadura Cabral, n??64, 4??G', '8200-179', 'Albufeira','Faro', 1, NULL, NULL),
(119, 'Rua Alves Correia, n??54, 3??Direito', '8200-179', 'Albufeira','Faro', 1, NULL, NULL),
(120, 'Rua Doutor Bernardino Ant??nio Gomes, n??1', '4940-534', 'Paredes de Coura','Viana do Castelo', 1, NULL, NULL);

INSERT INTO `promotor` (`promotor_nif`, `promotor_name`, `promotor_email`, `promotor_website`, `promotor_phonenumber`, `location_id`) VALUES
(510019285, 'Pdl-Parque dos Dinossauros da Lourinh??, Unipessoal Lda', 'geral@dinoparque.pt','https://www.dinoparque.pt/pt/', 261243160, 1),
(502741481, 'Associa????o M??sica, Educa????o e Cultura - O Sentido dos Sons', 'secretaria@metropolitana.pt', 'https://www.metropolitana.pt/', 213617320, 2),
(510856390, 'Meio Termo, Lda', 'geral@meiotermo.pt', 'https://www.meiotermo.pt/', 938556748, 3),
(509596614, 'Teatro Bocage - Associa????o Cultural', 'mail@teatrobocage.com', 'www.teatrobocage.com', 912449909, 4),
(501165614, 'Teatro Iberico-Centro de Cultura e Pesquisa de Arte Teatral', 'info@teatroiberico.org', 'https://teatroiberico.org/', 218682531, 5),
(513329455, 'Somos For??a de Produ????o, Lda', 'info@fproducao.pt', 'https://www.fproducao.pt/', 213621648, 6),
(500211086, 'Panoramica 35-Produ????o de Filmes Lda', 'panoramica35@p35.pt', 'https://www.p35.pt/', 213545154, 7),
(509321240, 'Prime Artists, Unipessoal Lda', 'geral@primeartists.eu', 'https://www.primeartists.eu/', 914182927, 8),
(503501999, 'Universal Music Portugal S.A', 'infopt@umusic.com', 'http://www.universalmusic.pt/', 217710410, 9),
(513191976, 'Bridgetown Talent Agency, Lda', 'bridgetown@gmail.com', 'https://bridgetown.pt/', 211222344, 10),
(506227871, 'By The Music, Produ????es Musicais Lda', 'producao@bythemusic.pt', 'https://bythemusic.pt/', 214574466, 11),
(504993011, 'Uau - Produ????o de Espect??culos, Lda', 'uau@uau.pt', 'https://www.uau.pt/',  213303500, 12),
(501439307, 'Centro Cultural e Desportivo dos Servidores do Munic??pio de Aveiro', 'geral@cm-aveiro.pt', 'https://www.cm-aveiro.pt/', 234406300, 13),
(509787770, 'Aacp - Associa????o de Arte Circense Portuguesa', 'aacp@aacp.pt', 'https://www.aacp.pt/',  214567983, 14),
(509700993, 'Associa????o tenda', 'geral@tenda.pt', 'https://tenda.pt/', 930687555, 15),
(502857145, 'Funda????o Centro Cultural de Bel??m', 'bilheteiraccb@ccb.pt ', 'https://www.ccb.pt/', 213612627 , 16),
(507903480, 'Everything Is New, Lda', 'geral@everythingisnew.pt', 'https://everythingisnew.pt/', 213933770, 17),
(506973123, 'Incubadora D artes - Produ????o de Espect??culos Lda', 'geral@incubadoradartes.com', 'http://www.incubadoradartes.com/pt/', 213611405, 18),
(514794801, 'Locomotiva Azul - Produ????o e Marketing Cultural, Unipessoal Lda', 'info@locomotivaazul.pt', 'https://www.locomotivaazul.pt/', 919417666, 19),
(515421367, 'Desert Rain Agency, Lda', 'geral@dra.pt', 'https://dra.pt/', 966777111, 20),
(505032481, 'Plano 6 - Produ????es Audio-Visuais Lda', 'info@plano6.pt', 'https://plano6.pt/', 213304152, 21);

INSERT INTO `event_space` (`event_space_id`, `name`, `space_type`, `email`, `website`, `phonenumber`, `location_id`) VALUES
('ES1', 'Aula Magna', 'Audit??rio', 'aulamagna@reitoria.ulisboa.pt', 'https://www.ulisboa.pt/espacos/aula-magna', 210113448, 22),
('ES2', 'Teatro S?? da Bandeira', 'Teatro', 'geral@teatrosadabandeira.pt', 'https://teatrosadabandeira.pt/', 222003595, 23),
('ES3', 'Centro de Congressos de Aveiro', 'Audit??rio', 'congressos@cm-aveiro.pt', 'https://www.cm-aveiro.pt/investidores/centro-de-congressos-de-aveiro',  234406300, 24),
('ES4', 'Teatro Bocage', 'Teatro', 'mail@teatrobocage.com', 'https://teatrobocage.wixsite.com/bocage', 912449909, 4),
('ES5', 'Teatro Ib??rico', 'Teatro', 'info@teatroiberico.org', 'http://www.teatroiberico.org/', 927510092, 5),
('ES6', 'Teatro Villaret', 'Teatro', 'info@fproducao.pt', 'http://ticketbuddy.sapo.pt/salas/sala/81', 213538586, 25),
('ES7', 'Museu Nacional dos Coches', 'Museu', 'comunica@mncoches.dgpc.pt', 'http://museudoscoches.gov.pt/pt/', 210732313, 26),
('ES8', 'O Lugar de Cabo Ruivo', 'Teatro', NULL, NULL, NULL, 27),
('ES9', 'Altice Arena', 'Arena', 'info@aarena.pt', 'http://www.alticearena.pt/', 218918409, 28),
('ES10', 'Campo Pequeno', 'Arena', 'geral@campopequeno.com', 'http://www.campopequeno.com/', 217998456, 29),
('ES11', 'Super Bock Arena', 'Arena', 'info@superbockarena.pt', 'http://www.superbockarena.pt/', 220503257, 30),
('ES12', 'Audit??rio Casino Estoril', 'Audit??rio', 'info.cestoril@estoril-sol.com', 'http://www.casino-estoril.pt/', 214667700, 31),
('ES13', 'Coliseu Porto Ageas', 'Arena', 'coliseu@coliseu.pt', 'http://www.coliseu.pt/', 223394947, 32),
('ES14', 'Teatro Aveirense', 'Teatro', 'info-teatroaveirense@cm-aveiro.pt', 'http://www.teatroaveirense.pt/', 234400920, 33),
('ES15', 'Teatro Maria Matos', 'Teatro', 'ticketbuddy@ticketbuddy.pt', 'https://teatromariamatos.pt/contacts/', 213621648, 34),
('ES16', 'Auditorio Municipal Augusto Cabrita', 'Audit??rio', 'dcpc@cm-barreiro.pt', 'http://barreiroamac.wordpress.com/', 212070578, 35),
('ES17', 'Teatro Armando Cortez', 'Teatro', 'info@teatroarmandocortez.pt', 'http://www.teatroarmandocortez.pt', 217110895, 37),
('ES18', 'Centro Cultural de Bel??m', 'Audit??rio', 'ccb@ccb.pt', 'http://www.ccb.pt/', 213612400, 16),
('ES19', 'Audit??rio Liceu Cam??es', 'Audit??rio', 'auditoriocamoes@gmail.com ', 'http://auditoriocamoes.wix.com/auditoriocamoes', 213190380, 37),
('ES20', 'Audit??rio Carlos Paredes', 'Audit??rio', 'cultura@jf-benfica.pt', 'http://www.jf-benfica.pt/', 217123000, 38),
('ES21', 'Dino Parque Lourinh??', 'Parque', 'geral@dinoparque.pt', 'https://www.dinoparque.pt/pt/', 261243160, 1);

INSERT INTO `event` (`event_id`, `event_description`, `event_type`, `start_date`, `end_date`, `viewers_min_age`, `promotor_nif`, `event_space_id`) VALUES
('E1', 'Ciclo 30 Anos | J??PITER', 'M??sica', '2019-06-02', NULL, 'M/06 anos', 502741481, 'ES7'),
('E2', 'LISBOA | BO??MIO', 'Stand Up Comedy', '2019-03-07', NULL, 'M/16 anos', 510856390, 'ES1'),
('E3', 'PORTO | BO??MIO', 'Stand Up Comedy', '2019-03-09', '2019-03-11', 'M/16 anos', 510856390, 'ES2'),
('E4', 'AVEIRO | BO??MIO', 'Stand Up Comedy', '2019-03-13', NULL, 'M/16 anos', 510856390, 'ES3'),
('E5', 'CHIADO COMEDY CLUB | Humor Negro', 'Stand Up Comedy', '2019-04-17', NULL, 'M/16 anos', 509596614, 'ES4'),
('E6', 'A Idade que Vem', 'Teatro', '2019-07-05', NULL, 'M/06 anos', 509596614, 'ES4'),
('E7', 'Somos Todos Cam??es', 'Teatro', '2019-04-11', '2019-04-12', 'M/06 anos', 501165614, 'ES5'),
('E8', 'VARIANTE BOLA', 'Teatro', '2019-09-07', '2019-09-15', 'M/16 anos', 513329455, 'ES6'),
('E9', 'VADIOS', 'Teatro', '2019-02-10', '2019-02-12', 'M/16 anos', 509596614, 'ES4'),
('E10', 'ALICE O OUTRO LADO DA HIST??RIA', 'Teatro Imersivo', '2020-06-10', '2020-06-23', 'M/16 anos', 500211086, 'ES8'),
('E11', 'EVANESCENCE', 'M??sica', '2020-04-18', NULL, 'M/06 anos', 509321240, 'ES9'),
('E12', 'TRIVIUM + HEAVEN SHALL BURN', 'M??sica', '2020-02-04', NULL, 'M/06 anos', 509321240, 'ES9'),
('E13', 'LISBOA | PANDA E OS CARICAS - O MUSICAL, NA ILHA', 'Mais Novos', '2020-12-18', '2020-12-19', 'Para todos', 503501999, 'ES10'),
('E14', 'PORTO | PANDA E OS CARICAS - O MUSICAL, NA ILHA', 'Mais Novos', '2020-12-26', '2020-12-27', 'Para todos', 503501999, 'ES11'),
('E15', 'PORTO | CONVERSAS DE MIGUEL AO VIVO', 'Stand Up Comedy', '2020-03-07', '2020-03-08', 'M/16 anos', 513191976, 'ES11'),
('E16', 'LISBOA | CONVERSAS DE MIGUEL AO VIVO', 'Stand Up Comedy', '2020-03-14', '2020-03-15', 'M/16 anos', 513191976, 'ES10'),
('E17', 'DUETOS CROSSOVER ??pera Rock ESPECIAL NATAL', '??pera', '2020-12-17', NULL, 'M/06 anos', 506227871, 'ES12'),
('E18', 'O LAGO DOS CISNES - RUSSIAN NATIONAL BALLET', 'Dan??a', '2020-10-13', NULL, 'M/06 anos', 504993011, 'ES13'),
('E19', 'CIRCOLANDO 20.20', 'Dan??a', '2020-11-07', NULL, 'M/12 anos', 501439307, 'ES14'),
('E20', 'Circo | Coliseu Porto Ageas 2021', 'Entretenimento', '2021-12-12', '2021-12-30', 'Para todos', 509787770, 'ES13'),
('E21', 'LISBOA | PERFEITOS DESCONHECIDOS', 'Teatro', '2021-12-09', '2021-12-23', 'M/12 anos', 513329455, 'ES15'),
('E22', 'BARREIRO | PERFEITOS DESCONHECIDOS', 'Teatro', '2021-12-29', NULL, 'M/12 anos', 513329455, 'ES16'),
('E23', 'PORTO  | PERFEITOS DESCONHECIDOS', 'Teatro', '2021-11-08', '2021-11-30', 'M/12 anos', 513329455, 'ES2'),
('E24', 'O FREUD EXPLICA', 'Teatro', '2021-01-19', '2021-01-30', 'M/12 anos', 509700993, 'ES17'),
('E25', 'PONTEN PIE: LOO','Teatro', '2021-04-30', NULL, 'Dos 3 aos 5 anos', 502857145, 'ES18'),
('E26', 'SCORPIONS: ROCK BELIEVER TOUR', 'M??sica', '2021-05-10', NULL, 'M/06 anos', 507903480, 'ES9'),
('E27', 'STACEY KENT', 'M??sica', '2021-05-06', NULL, 'M/06 anos', 506973123, 'ES18'),
('E28', 'TINDERSTICKS', 'M??sica', '2021-07-14', NULL, 'M/06 anos', 514794801, 'ES20'),
('E29', 'BLACK COFFEE LISBON | SBCNCSLY - TOUR', 'M??sica', '2021-11-22', NULL, 'M/16 anos', 515421367, 'ES19'),
('E30', 'Vitor Kley - A Bolha', 'M??sica', '2021-03-03', '2021-03-05', 'M/03 anos', 505032481, 'ES10'),
('E31', 'DINO PARQUE LOURINH??', 'Entretenimento', '2019-12-07', '2019-12-31', 'Para todos', 510019285, 'ES21');

INSERT INTO `session` (`session_id`, `session_date`, `start_hour`, `end_hour`, `time_of_day`, `week_day`, `number_of_tickets_available`, `event_id`) VALUES
('SS1', '2019-06-02', '17:00:00', NULL, 'Tarde', 'Domingo', 199, 'E1'),
('SS2', '2019-03-07', '22:00:00', NULL, 'Noite', 'Quinta-Feira', 98, 'E2'),
('SS3', '2019-03-09', '22:00:00', NULL, 'Noite', 'S??bado', 295, 'E3'),
('SS4', '2019-03-10', '22:00:00', NULL, 'Noite', 'Domingo', 297, 'E3'),
('SS5', '2019-03-11', '22:00:00', NULL, 'Noite', 'Segunda-Feira', 300, 'E3'),
('SS6', '2019-03-13', '22:00:00', NULL, 'Noite', 'Quarta-Feira', 198, 'E4'),
('SS7', '2019-04-17', '21:30:00', NULL, 'Noite', 'Quarta-Feira', 96, 'E5'),
('SS8', '2019-07-05', '20:00:00', NULL, 'Noite', 'Sexta-Feira', 149, 'E6'),
('SS9', '2019-04-11', '17:00:00', NULL, 'Tarde', 'Quinta-Feira', 87, 'E7'),
('SS10', '2019-04-12', '17:00:00', NULL, 'Tarde', 'Sexta-Feira', 90, 'E7'),
('SS11', '2019-09-07', '21:00:00', '22:15:00', 'Noite', 'S??bado', 96, 'E8'),
('SS12', '2019-09-14', '21:00:00', '22:15:00', 'Noite', 'S??bado', 150, 'E8'),
('SS13', '2019-02-10', '21:30:00', NULL, 'Noite', 'Domingo', 148, 'E9'),
('SS14', '2019-02-11', '21:30:00', NULL, 'Noite', 'Segunda-Feira', 150, 'E9'),
('SS15', '2019-02-12', '18:00:00', NULL, 'Tarde', 'Ter??a-Feira', 150, 'E9'),
('SS16', '2020-06-10', '21:00:00', '22:40:00', 'Noite', 'Ter??a-Feira', 49, 'E10'),
('SS17', '2020-06-10', '21:30:00', '23:10:00', 'Noite', 'Ter??a-Feira', 50,'E10'),
('SS18', '2020-06-10', '21:45:00', '23:25:00', 'Noite', 'Ter??a-Feira', 50, 'E10'),
('SS19', '2020-06-17', '21:00:00', '22:40:00', 'Noite', 'Quarta-Feira', 50, 'E10'),
('SS20', '2020-06-23', '21:45:00', '23:25:00', 'Noite', 'Ter??a-Feira', 48, 'E10'),
('SS21', '2020-04-18', '20:30:00', NULL, 'Noite', 'S??bado', 19994, 'E11'),
('SS22',  '2020-02-04', '18:30:00', NULL, 'Tarde', 'Ter??a-Feira', 19999, 'E12'),
('SS23', '2020-12-18', '11:00:00', NULL, 'Manh??', 'Sexta-Feira', 8999, 'E13'),
('SS24', '2020-12-18', '15:00:00', NULL, 'Tarde', 'Sexta-Feira', 8996, 'E13'),
('SS25', '2020-12-19', '11:00:00', NULL, 'Manh??', 'S??bado',  8997, 'E13'),
('SS26', '2020-12-26', '14:30:00', NULL, 'Tarde', 'S??bado',  4999, 'E14'),
('SS27', '2020-12-26', '18:00:00', NULL, 'Tarde', 'S??bado', 4998, 'E14'),
('SS28', '2020-12-27', '18:00:00', NULL, 'Tarde', 'Domingo', 5000, 'E14'),
('SS29', '2020-03-07', '21:30:00', NULL, 'Noite', 'S??bado', 97, 'E15'),
('SS30', '2020-03-08', '22:00:00', NULL, 'Noite', 'Domingo', 100, 'E15'),
('SS31', '2020-03-14', '21:30:00', NULL, 'Noite', 'S??bado', 199, 'E16'),
('SS32', '2020-03-15', '21:30:00', NULL, 'Noite', 'Domingo', 200, 'E16'),
('SS33', '2020-12-17', '21:00:00', NULL, 'Noite', 'Quinta-Feira', 345, 'E17'),
('SS34', '2020-10-13', '20:00:00', '22:20:00', 'Noite', 'Ter??a-Feira', 3998, 'E18'),
('SS35', '2020-11-07', '21:30:00', NULL, 'Noite', 'S??bado', 296, 'E19'),
('SS36', '2021-12-12', '17:30:00', NULL, 'Tarde', 'Domingo', 4000, 'E20'),
('SS37', '2021-12-15', '10:00:00', NULL, 'Tarde', 'Quarta-Feira', 3998, 'E20'),
('SS38', '2021-12-15', '21:00:00', NULL, 'Noite', 'Quarta-Feira', 4000, 'E20'),
('SS39', '2021-12-23', '15:00:00', NULL, 'Tarde', 'Quinta-Feira', 3999, 'E20'),
('SS40', '2021-12-23', '21:00:00', NULL, 'Noite', 'Quinta-Feira', 4000, 'E20'),
('SS41', '2021-12-29', '15:00:00', NULL, 'Tarde', 'Quarta-Feira', 4000, 'E20'),
('SS42', '2021-12-29', '21:00:00', NULL, 'Noite', 'Quarta-Feira', 4000, 'E20'),
('SS43', '2021-12-11', '21:00:00', NULL, 'Noite', 'S??bado', 444, 'E21'),
('SS44', '2021-12-17', '21:00:00', NULL, 'Noite', 'Sexta-Feira',  447, 'E21'),
('SS45', '2021-12-29', '21:00:00', NULL, 'Noite', 'Quarta-Feira', 498, 'E22'),
('SS46', '2021-11-08', '21:00:00', NULL, 'Noite', 'Segunda-Feira', 785, 'E23'),
('SS47', '2021-11-16', '21:00:00', NULL, 'Noite', 'Ter??a-Feira', 786, 'E23'),
('SS48', '2021-11-29', '21:00:00', NULL, 'Noite', 'Segunda-Feira', 786, 'E23'),
('SS49', '2021-01-22', '21:00:00', NULL, 'Noite', 'Sexta-Feira', 300, 'E24'),
('SS50', '2021-01-28', '21:00:00', NULL, 'Noite', 'Quinta-Feira', 298, 'E24'),
('SS51', '2021-04-30', '10:30:00', NULL, 'Manh??', 'Sexta-Feira', 1499, 'E25'),
('SS52', '2021-04-30', '16:00:00', NULL, 'Tarde', 'Sexta-Feira', 1500, 'E25'),
('SS53', '2021-05-10', '21:00:00', NULL, 'Noite', 'Segunda-Feira', 19994, 'E26'),
('SS54', '2021-05-06', '21:00:00', NULL, 'Noite', 'Quinta-Feira', 1495, 'E27'),
('SS55', '2021-07-14', '21:00:00', NULL, 'Noite', 'Quarta-Feira', 110, 'E28'),
('SS56', '2021-11-22', '16:00:00', NULL, 'Tarde', 'Segunda-Feira', 199, 'E29'),
('SS57', '2021-03-03', '21:30:00', '22:45:00', 'Noite', 'Quarta-Feira', 8994, 'E30'),
('SS58', '2019-12-07', '10:00:00', NULL, 'Manh??', 'Ter??a-Feira', 100000, 'E31'),
('SS59', '2019-12-10', '10:00:00', NULL, 'Manh??', 'Sexta-Feira', 99999, 'E31'),
('SS60', '2019-12-15', '10:00:00', NULL, 'Manh??', 'Quarta-Feira', 99999, 'E31'),
('SS61', '2019-12-31', '10:00:00', NULL, 'Manh??', 'Sexta-Feira', 100000, 'E31');

INSERT INTO `customer` (`customer_id`, `name`, `email`, `phonenumber`, `nif`, `location_id`) VALUES
('C1', 'Sara Silva', 'sarasilva307@hotmail.com', 915962531, 270527974, 45),
('C2', 'Ana Silva', 'afs307@hotmail.com', 915964399, 270527975, 45),
('C3', 'Ana Isabel Silva', 'isabelsilva307@msn.com', 968065320, 999999990, 45),
('C4', 'Jos?? Silva', 'josesilva307@msn.com', 934945152, 999999990, 45),
('C5', 'Beatriz Neto', 'beatrizneto2000@gmail.com', 963110979, 269192140, 46),
('C6', 'Jo??o Cruz', 'jcruz@gmail.com', 934561834, 999999990, 42),
('C7', 'Maria Jones', 'mariaj@hotmail.com', 914532689, 214573891, 52),
('C8', 'Pedro Calixto', 'pedro3452@msn.com', 912619534, 324152738, 60),
('C9', 'Albano Marques', 'amarques@outlook.com', 923364741, 235405861, 63),
('C10', 'Vasco Marques', 'vasco21@gmail.com', 931426384, 999999990, 105),
('C11', 'Margarida Vasconcelos', 'magguiev@novaims.unl.pt', 912357453, 216482942, 38),
('C12', 'Mariana Visconde', 'mvisconde123@gmail.com', 963824923, 273846193, 58),
('C13', 'Carlos Gabriel', 'carlosgabriel@msn.com', 924709641, 153427354, 58),
('C14', 'Fl??via Nunes', 'fn23571@outlook.com', 932536410, 294537193, 50),
('C15', 'Carolina Garcez', 'cgarcez@msn.com', 921555277, 280861537, 73),
('C16', 'Martim Manh??', 'martimmm@gmail.com', 965555003, 210315008, 77),
('C17', 'Marta Fernandes', 'mfernandes@outlook.com', 915552268, 211690996, 118),
('C18', 'Jo??o Fernandes', 'joaofernandes@msn.com', 935551623, 261919173, 66),
('C19', 'In??s Carvalho', 'inesc1999@gmail.com', 914263849, 999999990, 64),
('C20', 'Nuno Correia', 'nunocorreia@hotmail.com', 929003362, 217957242, 59),
('C21', 'Gabriela Silva', 'gabrielasilva3@gmail.com', 914372509, 999999990, 48),
('C22', 'Carolina Serro', 'serroc@outlook.com', 921351506, 246671904, 43),
('C23', 'Tiago Bagorro', 'tiagobagorro@msn.com', 930043050, 999999990, 89),
('C24', 'Beatriz Pires', 'biapires@gmail.com', 914362583, 297034707, 92),
('C25', 'In??s Agostinho', 'inesma@msn.com', 925309006, 255951965, 86),
('C26', 'Jo??o Pimenta', 'joaopim@outlook.com', 935001638, 249186233, 88),
('C27', 'Joana Pimenta', 'jpimenta@gmail.com', 914384520, 999999990, 88),
('C28', 'Roberto Peixeiro', 'robertop123@msn.com', 923648193, 249865637, 84),
('C29', 'Ricardo Guimar??es', 'ricardo64735@outlook.com', 935948517, 27090902, 90),
('C30', 'Rita Guerra', 'ritag5739@outlook.com', 917518899, 999999990, 80),
('C31', 'Diana Contantino', 'didiconst@gmail.com', 938776838, 219314020, 83),
('C32', 'Alice Vieira', 'alicinhavieirinha@msn.com', 968145506, 999999990, 81),
('C33', 'Rui Roxinol', 'ruiroxinol@gmail.com', 936199194, 999999990, 82),
('C34', 'Joana Costa', 'joaninhacostinha@msn.com', 934978756, 999999990, 69),
('C35', 'Cl??udio Costa', 'ccosta23@outlook.com', 910705908, 200859447, 69),
('C36', 'Catarina Couto', 'catscouto@msn.com', 937542110, 999999990, 47),
('C37', 'Cristiano Ronaldo', 'cristianinhoronald@hotmail,com', 935588911, 208373233, 112),
('C38', 'Daniel Carreira', 'daniscarreira76@gmail.com', 939874872, 270042610, 113),
('C39', 'Diogo Almeida', 'dioguesalmeidao@msn.com', 918380234, 999999990, 96),
('C40', 'D??bora Figueira', 'deborafigueira123@outlook.com', 960487502, 999999990, 85),
('C41', 'Francisco Frad??o', 'xicofradao@msn.com', 962446491, 281756864, 54),
('C42', 'F??bio Selid??nio', 'fabzsel@gmail.com', 916864473, 999999990, 44),
('C43', 'Beatriz Selid??nio', 'beaselidonio89@gmail.com', 962166295, 999999990, 44),
('C44', 'Filipe Felizardo', 'pipofeliz@outlook.com', 924245011, 253206588, 72),
('C45', 'Ana Fena', 'aninhas24@msn.com', 915482594, 257319364, 78),
('C46', 'Rafael Gai??o', 'rafaga54725@msn.com', 927600838, 999999990, 94),
('C47', 'Rui Amaral', 'ruifixe@outlook.com', 962991069, 242909039, 108),
('C48', 'Gustavo Inglesias', 'gustingles@gmail.com', 919768333, 999999990, 99),
('C49', 'Louredana Stefe', 'loure64836@msn.com', 965466973, 281262034, 97),
('C50', 'Mariana Serol', 'marianaserolas@outlook.com', 915274922, 211868744, 116),
('C51', 'M??rio Soares', 'marinhosoares@outlook.com', 913846290, 22982368, 70),
('C52', 'Gustavo Laranjeira', 'gustvlaranja@outlook.com', 935472940, 999999990, 39),
('C53', 'Alecrim Meireles', 'alecmeire@gmail.com', 937491003, 999999990, 119),
('C54', 'Hort??ncia Cabral', 'hortelacabrinha@msn.com', 919834863, 999999990, 93),
('C55', 'Constan??a Alexandre', 'constfofinha21@gmail.com', 935909240, 219644675, 103),
('C56', 'Valentina Dobresco', 'valentinalove67@outlook.com', 927380599, 253066816, 101),
('C57', 'Marco Dobresco', 'marquinh54@msn.com', 915712786, 256556334, 101),
('C58', 'Miguel Sequeira', 'miguiseq1@hotmail.com', 967107457, 999999990, 75),
('C59', 'Yuri Lambda', 'yurigagarinspace123@gmail.com', 968508038, 999999990, 56),
('C60', 'Rita Guerreira', 'ritareadytobattle@hotmail.com', 914093290, 999999990, 107),
('C61', 'Ana Mota', 'anocasmotinha@hotmail.com', 918049942, 225662620, 109),
('C62', 'Rute Marlene', 'rutesmarly@gmail.com', 964377077, 999999990, 120),
('C63', 'Angelico Milte', 'angelmiltao@msn.com', 914688075, 233344390, 40),
('C64', 'Ant??nio Pedras', 'antoninhorochas@gmail.com', 963073750, 237911590, 87),
('C65', 'Bia Barrocas', 'bibibarro@gmail.com', 937295625, 231833334, 71),
('C66', 'Bernardo Paulo', 'bennypaulinho@outlook.com', 962608967, 999999990, 61),
('C67', 'Bernardina Baganha', 'bennyfofinha@msn.com', 965693627, 251094758, 49),
('C68', 'Joana Brito', 'joaninha78@gmail.com', 925545644, 268619174, 55),
('C69', 'Carlota Ferreira', 'carlotaferr45@outlook.com', 966974770, 999999990, 65),
('C70', 'Diogo Dami??o', 'dioguidams@gmail.com', 910128336, 257559132, 107),
('C71', 'Jo??o Guedes', 'jotaguedes@hotmail.com', 925096700, 999999990, 111),
('C72', 'Rui Amaral', 'ruiamaral999@gmail.com', 963130784, 233708588, 117),
('C73', 'M??rio Soares', 'marinho45@hotmail.com', 937806243, 262612747, 95),
('C74', 'Beatriz Pires', 'beatrizpires@gmail.com', 932489954, 999999990, 102),
('C75', 'Sara Silva', 'sarocassilvocas@hotmail.com', 917611610, 999999990, 51),
('C76', 'Ant??nio Pedras', 'antoniopedras12@hotmail.com', 934628009, 245391009, 53),
('C77', 'Rui Amaral', 'ruiamor23@gmail.com', 967278506, 999999990, 79),
('C78', 'Filipa Cabano', 'f_cabano23@hotmail.com', 961892138, 258199490, 100),
('C79', 'Catarina Rato', 'catsmouse@gmail.com', 962274412, 999999990, 68),
('C80', 'Ruben Ruas', 'rubenstreets@hotmail.com', 926411432, 281269971, 110),
('C81', 'Ana Silva', 'aninhassilva@msn.com', 939205310, 999999990, 114),
('C82', 'Gon??alo Vargas', 'gongasvargosa@hotmail.com', 963545785, 999999990, 91),
('C83', 'Beatriz Neto', 'bea_neto@hotmail.com', 913879284, 211536490, 76),
('C84', 'Jo??o Trindade', 'jotatrindade@gmail.com', 969570460, 236150758, 57),
('C85', 'Beatriz Pires', 'biapires123@msn.com', 912241816, 999999990, 62),
('C86', 'Tiago Figueira', 'tiaguinhofigueiras@outlook.com', 916300760, 284338974, 98),
('C87', 'Tiago Valido', 'tiagovalas@gmail.com', 963196605, 999999990, 104),
('C88', 'Paula Vicente', 'paulinhavicente@hotmail.com', 934579787, 999999990, 106);

INSERT INTO `rating` (`rating_id`, `rating_datetime`, `rating_value`, `comment`, `customer_id`, `session_id`) VALUES
(1, '2019-03-14 12:00:00',  4, 'Espetaculo otimo!', 'C12', 'SS6'),
(2, '2019-03-14 11:00:00', 3, 'Demorei muito tempo para entrar e o bilhete foI caro.', 'C4', 'SS2'),
(3, '2019-03-12 23:00:00', 5, 'Espetaculo fantastico com artistas muito talentosos. A repetir', 'C7', 'SS3'),
(4, '2019-04-02 11:45:00',  2, 'O espetaculo nao foi de todo ao encontro do que esperava. Horrivel', 'C8', 'SS4'),
(5, '2019-03-23 15:44:00', 3, 'Espetaculo razoavel. Mas o pre??o foi muito caro', 'C11', 'SS6'),
(6, '2019-04-24 18:00:00', 4, 'Espetaculo bastante bom. N??o contava com tanta organiza????o.', 'C14', 'SS7'),
(7, '2019-06-22 17:27:00', 4, 'Espetaculo fantastico. Artistas Top', 'C6', 'SS1'),
(8, '2021-12-22 23:00:00', 5, 'Maravilhoso.A minha familia adorou. Foi perfeito','C30', 'SS37' ),
(9, '2020-06-24 11:00:00', 3, 'Foi bom mas esperava mais do espa??o organizador e dos artistas em palco', 'C36', 'SS20'),
(10, '2021-12-14 11:12:00', 5, '?? fantastico hoje em dia se dar valor a este tipo de eventos. Obrigada aos artistas pela sua enorme performance!', 'C40', 'SS43'),
(11, '2021-03-06 17:00:00',  4, 'Espetaculo otimo mas em termos de acesso n??o foi nada de espetacular', 'C43', 'SS57'),
(12, '2021-05-13 13:19:00 ', 2, 'Deviam ter vergonha de cobrar o pre??o que cobraram por bilhete e depois come??ar tudo atrasado.', 'C48', 'SS53'),
(13, '2021-07-29 12:00:00', 3, 'Gostei do evento mas era um espa??o muito pequeno para tanta gente', 'C51', 'SS55'),
(14, '2019-12-22 22:00:00', 1, 'Sala suja, a performance dos artistas p??ssima. ?? por isso que n??o h?? mais investimentos na cultura em Portugal', 'C56', 'SS59'),
(15, '2020-03-10 21:00:00', 5, 'O bilhete foi me oferecido e foi sem duvida uma das melhores prendas que j?? recebi. Organiza????o 5 e Performance 5!', 'C60', 'SS29'),
(16, '2020-06-27 19:09:00', 3, 'Para al??m de ter levado duas horas a entrar na sala, os funcionarios n??o foram nada prestaveis', 'C62', 'SS20'),
(17, '2021-12-31 22:00:00', 4, 'Espetaculo ok! Funcionarios super simpaticos e prestaveis.', 'C64', 'SS45'),
(18, '2021-05-15 13:00:00', 3, 'O artista n??o estava nos seus dias e a organiza????o do evento era desastrosa', 'C10', 'SS53'),
(19, '2021-05-18 14:23:00', 5, 'Espetaculo otimo! O meu filho adorou! Artistas muito animados e comunicativos com o seu publico.', 'C66', 'SS53'),
(20, '2021-05-10 15:16:00', 5, 'Melhor performance que vi nos ultimos anos, tanto em Portugal como no estrangeiro!', 'C68', 'SS54'),
(21, '2021-07-17 18:30:00', 5, 'Espetaculo do s??culo. Foi muito emotivo tanto para o publico como para o artista', 'C70', 'SS55'),
(22, '2019-03-10 19:15:00', 3, 'Visto o pre??o a que os bilhetes foram vendidos n??o percebo como a sala estava no estado em que estava. Para n??o falar dos funcionarios...', 'C76', 'SS3'),
(23, '2019-04-20 20:30:00', 3, 'Foi bom mas n??o foi fantastico.', 'C79', 'SS7'),
(24, '2019-09-22 22:39:00', 4, 'Comprei os bilhetes por vontade do meu marido e n??o me arrependi de o ter feito. O acesso ao pavilhao foi r??pido e os empregados sempre prontos ajudar', 'C83', 'SS11'),
(25, '2019-09-24 22:49:00', 4, 'Espetaculo maravilhoso! Se n??o fosse a falta de apoio na entrada na sala teria sido 5','C84', 'SS11'),
(26, '2019-09-13 08:08:00', 2, 'A ideia era boa mas os artistas n??o conseguiram chegar ??s pessoas. Foi uma seca', 'C82', 'SS11'),
(27, '2020-12-19 23:00:00', 5, 'Adorei do primeiro ao ultimo minuto!', 'C26', 'SS33'),
(28, '2020-12-19 21:00:00', 3, 'Para al??m da organiza????o ser fraca, os artistas estiverem bastante mal', 'C27', 'SS33'),
(29, '2021-12-31 14:32:00', 4, 'Espetaculo muito bom. Foi pena a sala ser t??o pequena para tanta gente','C41', 'SS45'),
(30, '2021-01-29 16:04:00', 3, 'Espetaculo  bom.','C65', 'SS50');

INSERT INTO `promotion` (`promotion_id`, `promotion_code`, `promotion_description`, `start_date`, `end_date`, `promotion_rate`) VALUES
('P0', NULL, NULL, NULL, NULL, 0.00),
('P1', 'NATAL2019', 'Promo????o de Natal 2019', '2019-12-12', '2019-12-26', 0.10),
('P2', 'NATAL2020', 'Promo????o de Natal 2020', '2020-12-12', '2020-12-26', 0.10),
('P3', 'NATAL2021', 'Promo????o de Natal 2021', '2021-12-12', '2021-12-26', 0.10),
('P4', 'ANONOVO2019-2020', 'Promo????o Ano Novo 2019-2020', '2019-12-31', '2020-01-01', 0.15),
('P5', 'ANONOVO2020-2021', 'Promo????o Ano Novo 2020-2021', '2020-12-31', '2021-01-01', 0.15),
('P6', 'PASCOA2019', 'Promo????o P??scoa 2019', '2019-04-20', '2019-04-22', 0.05),
('P7', 'PASCOA2020', 'Promo????o P??scoa 2020', '2020-04-11', '2020-04-13', 0.05),
('P8', 'PASCOA2021', 'Promo????o P??scoa 2021', '2021-04-03', '2021-04-05', 0.05),
('P9', 'DIANAMORADOS2019', 'Promo????o Dia de S??o Valentim 2019', '2019-02-14', '2019-02-14', 0.10),
('P10', 'DIANAMORADOS2020', 'Promo????o Dia de S??o Valentim 2020', '2020-02-14', '2020-02-14', 0.10),
('P11', 'DIANAMORADOS2021', 'Promo????o Dia de S??o Valentim 2021', '2021-02-14', '2021-02-14', 0.10),
('P12', 'DIACRIANCA2019', 'Promo????o Dia da Crian??a 2019', '2019-06-01', '2019-06-01', 0.20),
('P13', 'DIACRIANCA2020', 'Promo????o Dia da Crian??a 2020', '2020-06-01', '2020-06-01', 0.20),
('P14', 'DIACRIANCA2021', 'Promo????o Dia da Crian??a 2021', '2021-06-01', '2021-06-01', 0.20),
('P15', 'VERAO2019', 'Promo????o Ver??o 2019', '2019-08-01', '2019-08-15', 0.07),
('P16', 'VERAO2020', 'Promo????o Ver??o 2020', '2020-08-01', '2020-08-15', 0.07),
('P17', 'VERAO2021', 'Promo????o Ver??o 2021', '2021-08-01', '2021-08-15', 0.07),
('P18', 'BLACKFRIDAY2019', 'Black Friday 2019', '2019-11-29', '2019-11-29', 0.20),
('P19', 'BLACKFRIDAY2020', 'Black Friday 2020', '2020-11-27', '2020-11-27', 0.20),
('P20', 'BLACKFRIDAY2021', 'Black Friday 2021', '2021-11-26', '2021-11-26', 0.20),
('P21', 'CYBERMONDAY2019', 'Cyber Monday 2019', '2019-12-02', '2019-12-02', 0.05),
('P22', 'CYBERMONDAY2020', 'Cyber Monday 2020', '2020-11-30', '2020-11-30', 0.05),
('P23', 'CYBERMONDAY2021', 'Cyber Monday 2021', '2021-11-29', '2021-11-29', 0.05);

INSERT INTO `zone` (`zone_id`, `session_id`, `zone_description`, `ticket_unit_price`, `event_space_id`) VALUES
('Z1',  'SS2', 'Anfiteatro', 18.00, 'ES1'), 
('Z2', 'SS2', 'Doutorais', 25.00, 'ES1'),
('Z3', 'SS1', 'Plateia', 15.00, 'ES7'),
('Z4', 'SS3', 'Plateia', 20.00, 'ES2'),
('Z5', 'SS4', 'Cadeiras Orquesta', 25.00, 'ES2'),
('Z6', 'SS6', '1?? Plateia', 20.00, 'ES3'),
('Z7', 'SS6', '2?? Plateia', 18.00, 'ES3'),
('Z8', 'SS7', 'Plateia', 8.50, 'ES4'),
('Z9', 'SS7', 'Mobilidade Condicionada', 8.50, 'ES4'), 
('Z10', 'SS9', 'Plateia', 5.00, 'ES5'),
('Z11', 'SS11', 'Plateia', 14.40, 'ES6'),
('Z12', 'SS16', 'Sem zona', 30.00, 'ES8'),
('Z13', 'SS21', 'Balc??o 1- Sector 12', 45.00, 'ES9'),
('Z14', 'SS21', 'Balc??o 1- Sector 2', 70.00, 'ES9'),
('Z15', 'SS21', 'Mobilidade Condicionada', 40.00, 'ES9'),
('Z16', 'SS23', 'Galerias 1?? Impar', 17.50, 'ES10'),
('Z17', 'SS25', 'Bancada Sector 2.', 20.00, 'ES10'),
('Z18', 'SS24', 'Plateia Lateral A Par', 27.50, 'ES10'),
('Z19', 'SS26', 'Balc??o 0 - Sector B', 25.00, 'ES11'),
('Z20', 'SS27', 'Balc??o 2 - Sector A', 18.00, 'ES11'),
('Z21', 'SS33', 'Plateia A - D', 25.00, 'ES12'),
('Z22', 'SS33', 'Plateia K - O', 20.00, 'ES12'),
('Z23', 'SS37', 'Camarote 1?? Par', 18.00, 'ES13'),
('Z24', 'SS39', 'Camarote 2?? Par', 8.00, 'ES13'),
('Z25', 'SS8', 'Plateia', 8.00, 'ES4'),
('Z26', 'SS13', 'Mobilidade Condicionada', 6.00, 'ES4'),
('Z27', 'SS22', 'PLATEIA EM P??', 32.00, 'ES9'),
('Z28', 'SS29', 'Balc??o 1 - Sector B', 15.00, 'ES11'),
('Z29', 'SS20', 'Balc??o 2 - Sector D', 12.50, 'ES11'),
('Z30', 'SS31', 'Plateia Lateral Vip Impar', 30.00, 'ES10'),
('Z31', 'SS34', 'Camarote 1?? Par|V.Reduz', 20.00, 'ES13'),
('Z32', 'SS35', 'Plateia', 5.00, 'ES14'),
('Z33', 'SS43', 'Balc??o', 12.80, 'ES15'),
('Z34', 'SS45', 'Frisa Par', 15.00, 'ES16'),
('Z35', 'SS46', 'Mobilidade Condicionada', 16.00, 'ES2'),
('Z36', 'SS50', 'Plateia', 18.00, 'ES17'),
('Z37', 'SS51', 'Plateia', 7.00, 'ES18'),
('Z38', 'SS53', 'Balc??o 1 - Sector 17 (I)', 55.00, 'ES9'),
('Z39', 'SS53', 'balc??o1-Sect 7(Ii)Vis.Red', 45.00, 'ES9'),
('Z40', 'SS54', '2?? Balc??o', 22.50, 'ES18'),
('Z41', 'SS55', 'Balc??o Popular Direito', 25.00, 'ES13'),
('Z42', 'SS55', 'Frisa Par', 30.00, 'ES13'),
('Z43', 'SS56', 'Palco', 150.00, 'ES10'),
('Z44', 'SS57', 'Cam.1?? Par-Mob. Reduzida', 20.00, 'ES10'),
('Z45', 'SS57', 'Camarotes 2?? Par', 20.00, 'ES10'),
('Z46', 'SS60', 'Adulto', 13.00, 'ES21'),
('Z47', 'SS59', 'Crian??a 4-12 Anos (Incl)', 9.90, 'ES21');

INSERT INTO `seat` (`seat_id`, `seat_code`, `zone_id`) VALUES
('S1', 'Sem marca????o', 'Z1'),
('S2', 'Sem marca????o', 'Z2'),
('S3', 'Sem marca????o', 'Z3'),
('S4', 'L-29', 'Z4'),
('S5', 'H-5', 'Z5'),
('S6', 'Sem marca????o', 'Z6' ),
('S7', 'Sem marca????o', 'Z7' ),
('S8', 'C-15', 'Z8' ),
('S9', 'H-14', 'Z9'),
('S10', 'G-4' , 'Z10' ),
('S11', 'F-19', 'Z11' ),
('S12', 'Sem marca????o', 'Z12'),
('S13', 'E-2', 'Z13'),
('S14', 'H-1' , 'Z14' ),
('S15', 'Sem marca????o' , 'Z15'),
('S16', 'A-85', 'Z16'),
('S17', 'N-27', 'Z17'),
('S18', 'T-40', 'Z18'),
('S19', 'I-9', 'Z19'),
('S20', 'D-24', 'Z20'),
('S21', 'C-17', 'Z21'),
('S22','K-2', 'Z22'),
('S23', '10-1', 'Z23'),
('S24', '1-6', 'Z24'),
('S25', 'I-9' , 'Z25'),
('S26', 'H-15', 'Z26'),
('S27', 'Sem marca????o', 'Z27'),
('S28', 'C-27', 'Z28'),
('S29', 'A-5', 'Z29'),
('S30', 'K-47', 'Z30'),
('S31', '30-1', 'Z31'),
('S32', 'B-21', 'Z32'),
('S33', 'E-9', 'Z33'),
('S34', 'A-6', 'Z34'),
('S35', 'F-27', 'Z35'),
('S36', 'I-29', 'Z36'),
('S37', 'Sem marca????o', 'Z37'),
('S38', 'F-17', 'Z38'),
('S39', 'A-11', 'Z39'),
('S40', 'A-33', 'Z40'),
('S41', 'A-18', 'Z41'),
('S42', '4-1', 'Z42'),
('S43', 'Sem marca????o', 'Z43'),
('S44', '14-1', 'Z44'),
('S45', '2-1', 'Z45'),
('S46', 'Sem marca????o', 'Z46'),
('S47', 'Sem marca????o', 'Z47'),
('S48', 'D-24', 'Z21'),
('S49', '12-4', 'Z23'),
('S50', 'H-16', 'Z26'),
('S51', 'E-28', 'Z28'),
('S52', 'F-35', 'Z28'),
('S53', 'A-6', 'Z29'),
('S54', '30-2', 'Z31'),
('S55', 'B-19', 'Z32'),
('S56', 'B-17', 'Z32'),
('S57', 'B-15', 'Z32'),
('S58', 'A-10', 'Z34'),
('S59', 'I-27', 'Z36'),
('S60', 'G-5', 'Z38'),
('S61', 'G-7', 'Z38'),
('S62', 'A-9', 'Z39'),
('S63', 'A-2', 'Z39'),
('S64', 'B-33', 'Z40'),
('S65', 'C-33', 'Z40'),
('S66', 'A-11', 'Z41'),
('S67', 'A-1', 'Z41'),
('S68', '8-6', 'Z42'),
('S69', '30-1', 'Z44'),
('S70', '30-6', 'Z44'),
('S71', '2-2', 'Z45'),
('S72', '14-1', 'Z45'),
('S73', 'S-20', 'Z4'),
('S74', 'S-28', 'Z4'),
('S75', 'H-29', 'Z5'),
('S76', 'D-26', 'Z5'),
('S77', 'I-9', 'Z8'),
('S78', 'H-15', 'Z9'),
('S79', 'A-4', 'Z10'),
('S80', 'N-17', 'Z11'),
('S81', 'B-14', 'Z11'),
('S82', 'F-20', 'Z11'),
('S83', 'N-7', 'Z17'),
('S84', 'M-11', 'Z17'),
('S85', 'B-9', 'Z20'),
('S86', 'F-15', 'Z13'),
('S87', 'C-9', 'Z13'),
('S88', 'F-16', 'Z13'),
('S89', 'B-7', 'Z21'),
('S90', 'B-9', 'Z21'),
('S91', 'A-13', 'Z40'),
('S92', 'A-11', 'Z40'),
('S93', 'J-2', 'Z4'),
('S94', 'S-28', 'Z4'),
('S95', 'N-46', 'Z18'),
('S96', 'N-48', 'Z18'),
('S97', 'S-30', 'Z18'),
('S98', 'A-6', 'Z33'),
('S99', 'A-12', 'Z33'),
('S100', 'D-17', 'Z10');

INSERT INTO `ticket` (`bar_code`, `seat_id`) VALUES
(1110527482421, 'S1'),
(1110491697920, 'S2'),
(1110456845632, 'S3'),
(1110123456789, 'S4'),
(1110098765432, 'S5'),
(1110987654321, 'S6'),
(1110876543210, 'S7'),
(1110765432109, 'S8'),
(1110654321098, 'S9'),
(1110543210987, 'S10'),
(1110432109876, 'S11'),
(1110321098765, 'S12'),
(1110210987654, 'S13'),
(1110109876543, 'S14'),
(1110019283746, 'S15'),
(1110928374659, 'S16'),
(1110746583746, 'S17'),
(1110016592837, 'S18'),
(1110120910290, 'S19'),
(1110928392839, 'S20'),
(1110837467845, 'S21'),
(1110657465746, 'S22'),
(1110107283464, 'S23'),
(1110365802653, 'S24'),
(1110986467647, 'S25'),
(1110098702318, 'S26'),
(1110123413245, 'S27'),
(1110646709738, 'S28'),
(1110941419453, 'S29'),
(1110439453744, 'S30'),
(1110463253263, 'S31'),
(1110822344268, 'S32'),
(1110561232248, 'S33'),
(1110298374566, 'S34'),
(1110334455667, 'S35'),
(1110998877665, 'S36'),
(1110112233445, 'S37'),
(1110223344556, 'S38'),
(1110009988776, 'S39'),
(1110887766545, 'S40'),
(1110776655434, 'S41'),
(1110665544332, 'S42'),
(1110443352729, 'S43'),
(1110000098668, 'S44'),
(1110333474749, 'S45'),
(1110442221223, 'S46'),
(1110334488773, 'S47'),
(1110009272524, 'S48'),
(1110112222334, 'S49'),
(1110666677888, 'S50'),
(1110555666677, 'S51'),
(1110555332111, 'S52'),
(1110887665554, 'S53'),
(1110445667778, 'S54'),
(1110008866544, 'S55'),
(1110333332222, 'S56'),
(1110111222334, 'S57'),
(1110339876545, 'S58'),
(1110987645673, 'S59'),
(1110233423534, 'S60'),
(1110234435455, 'S61'),
(1110289777665, 'S62'),
(1110232435466, 'S63'),
(1110867887667, 'S64'),
(1110765867766, 'S65'),
(1110645646575, 'S66'),
(1110111112222, 'S67'),
(1110222222233, 'S68'),
(1110999999888, 'S69'),
(1110555555555, 'S70'),
(1110333322222, 'S71'),
(1110000000111, 'S72'),
(1110122222222, 'S73'),
(1110444444444, 'S74'),
(1110666666666, 'S75'),
(1110777778888, 'S76'),
(1110444444333, 'S77'),
(1110222211111, 'S78'),
(1110999999999, 'S79'),
(1110666777774, 'S80'),
(1110444444433, 'S81'),
(1110212121212, 'S82'),
(1110232223232, 'S83'),
(1110343434343, 'S84'),
(1110454545454, 'S85'),
(1110565656565, 'S86'),
(1110565676767, 'S87'),
(1110454545332, 'S88'),
(1110989898989, 'S89'),
(1110090900909, 'S90'),
(1110121212121, 'S91'),
(1110265542222, 'S92'),
(1110765465656, 'S93'),
(1110454656546, 'S94'),
(1110678657856, 'S95'),
(1110334333333, 'S96'),
(1110222222334, 'S97'),
(1110999888877, 'S98'),
(1110555556565, 'S99'), 
(1110346455342, 'S100');

INSERT INTO `order_` (`order_id`, `order_datetime`, `promotion_id`, `customer_id`) VALUES
('O1', '2021-01-30 03:40:53', 'P0', 'C1'),
('O2', '2019-02-22 15:03:01', 'P0', 'C4'),
('O3', '2019-02-14 10:22:45', 'P9', 'C5'),
('O4', '2019-06-01 14:01:01', 'P12', 'C6'),
('O5', '2018-12-28 00:14:18', 'P0', 'C7'),
('O6', '2019-03-09 13:20:06', 'P0', 'C8'),
('O7', '2019-03-06 18:09:34', 'P0', 'C5'), 
('O8', '2019-02-14 11:11:11', 'P9', 'C11'),
('O9', '2019-02-01 12:55:06', 'P0', 'C12'),
('O10', '2019-04-16 13:12:03', 'P0', 'C13'),
('O11', '2019-03-31 19:19:00', 'P0', 'C14'),
('O12', '2019-04-01 20:19:02', 'P0', 'C15'),
('O13', '2019-08-10 22:34:33', 'P15', 'C16'),
('O14', '2019-04-21 23:40:03', 'P7' , 'C17'),
('O15', '2020-02-20 21:09:00', 'P0', 'C18'),
('O16', '2020-01-01 11:12:13', 'P4', 'C19'),
('O17', '2020-04-01 09:09:54', 'P0', 'C20'),
('O18', '2020-11-27 18:30:00', 'P19', 'C21'),
('O19', '2019-03-01 12:22:12', 'P0', 'C39'),
('O20', '2020-11-30 08:56:05', 'P22', 'C22'),
('O21', '2020-09-20 16:23:33', 'P0', 'C23'),
('O22', '2020-12-15 12:03:22', 'P2' , 'C24'),
('O23', '2020-12-02 16:30:30', 'P0', 'C25'),
('O24', '2020-11-27 07:55:05', 'P19', 'C28'),
('O25', '2020-11-30 15:00:00', 'P0', 'C29'), 
('O26', '2021-11-01 13:30:12', 'P0', 'C30'),
('O27', '2021-08-06 12:12:12', 'P17', 'C31'),
('O28', '2019-05-26 06:06:06' , 'P0', 'C32'),
('O29', '2019-02-09 10:09:07', 'P0', 'C33'),
('O30', '2020-02-02 12:22:01', 'P0', 'C34'),
('O31', '2019-12-31 14:54:54', 'P4' ,'C35'),
('O32', '2020-06-01 02:32:34', 'P13' ,'C36'),
('O33', '2020-02-28 08:09:00', 'P0',  'C37'),
('O34', '2020-09-30 15:15:15', 'P0', 'C38'),
('O35', '2020-10-23 19:43:24', 'P0', 'C39'),
('O36', '2021-11-26 20:21:01', 'P20', 'C40'),
('O37', '2021-12-01 15:34:02' , 'P0', 'C41'),
('O38', '2021-11-01 16:12:01', 'P0', 'C44'),
('O39', '2021-01-26 21:23:34', 'P0', 'C45'),
('O40', '2021-03-29 14:43:34', 'P0','C46'),
('O41', '2021-04-03 18:18:09', 'P8','C47'),
('O42', '2021-02-01 13:43:54', 'P0', 'C48'),
('O43', '2021-04-27 01:10:01', 'P0','C49'),
('O44', '2021-07-10 23:56:23', 'P0','C50'),
('O45', '2020-12-31 22:21:12', 'P5', 'C51'),
('O46', '2021-10-20 16:06:33', 'P0', 'C52'),
('O47', '2021-03-01 10:10:10', 'P0','C53'),
('O48', '2021-02-14 09:07:56', 'P11','C54'),
('O49', '2019-12-15 07:45:32', 'P0', 'C55'),
('O50', '2019-12-10 09:06:44', 'P0','C56'),
('O51', '2020-11-30 11:21:01', 'P22','C57'),
('O52', '2021-11-26 17:33:45','P20','C58'),
('O53', '2019-02-10 09:09:09', 'P0','C59'),
('O54', '2019-12-27 14:23:24', 'P0', 'C60'),
('O55', '2020-01-20 20:48:32', 'P0','C61'),
('O56', '2020-06-01 14:30:22','P13','C62'),
('O57', '2020-10-01 07:59:00', 'P0','C63'),
('O58', '2019-09-06 14:02:01', 'P0','C1'),
('O59', '2020-11-07 15:00:00', 'P0','C2'),
('O60', '2020-11-03 12:13:40', 'P0','C3'),
('O61', '2021-11-09 13:07:04', 'P23','C64'),
('O62', '2021-01-01 12:32:12', 'P5','C65'),
('O63', '2021-04-30 09:08:07', 'P0','C9'),
('O64', '2020-08-03 06:23:02','P16','C10'),
('O65', '2021-01-21 11:00:00', 'P0','C66'),
('O66', '2021-05-04 08:08:45', 'P0', 'C67'),
('O67', '2021-05-01 19:00:06', 'P0','C68'),
('O68', '2021-03-15 12:12:13', 'P0','C69'),
('O69', '2021-07-07 08:00:45', 'P0', 'C70'),
('O70', '2021-04-05 08:20:47', 'P8', 'C71'),
('O71', '2020-11-20 12:00:00', 'P0', 'C72'),
('O72', '2021-02-14 05:45:45', 'P11','C42'),
('O73', '2021-01-27 04:00:09', 'P0','C43'),
('O74', '2021-03-03 15:30:58', 'P0','C73'),
('O75', '2021-01-28 03:09:08', 'P0', 'C74'),
('O76', '2019-02-14 13:35:45', 'P9','C75'),
('O77', '2018-11-10 09:17:50', 'P0','C76'),
('O78', '2018-09-30 14:55:00', 'P0','C77'),
('O79', '2019-01-05 00:00:00', 'P0', 'C78'),
('O80', '2019-04-09 23:45:02', 'P0','C79'),
('O81', '2019-02-23 10:10:24' , 'P0','C80'),
('O82', '2019-02-19 19:19:08', 'P0','C81'),
('O83', '2019-08-09 07:37:39', 'P15', 'C82'),
('O84', '2019-09-03 13:40:13', 'P0','C83'),
('O85', '2019-08-30 09:09:09', 'P0', 'C84'),
('O86', '2020-12-15 14:40:32', 'P2', 'C85'),
('O87', '2020-09-17 12:39:00', 'P0', 'C86'),
('O88', '2020-11-27 15:56:06', 'P19','C87'),
('O89', '2020-04-02 12:12:12', 'P0','C88'),
('O90', '2020-10-19 14:34:50', 'P0','C26'),
('O91', '2020-09-13 13:23:32', 'P0', 'C27'),
('O92', '2021-09-22 23:50:00', 'P0', 'C5'),
('O93', '2019-04-11 10:10:09', 'P0', 'C50');

INSERT INTO `order_items` (`order_id`, `bar_code`, `insurance`) VALUES
('O1', 1110121212121, 0.00),
('O1', 1110265542222, 0.00),
('O2', 1110527482421, 1.20),
('O3', 1110491697920, 1.20),
('O4', 1110456845632, 0.00),
('O5', 1110123456789, 0.00),
('O6', 1110098765432, 1.20),
('O7', 1110454545332 , 0.00),
('O7', 1110765465656 , 0.00),
('O7', 1110334333333 , 0.00),
('O8', 1110987654321 , 1.20),
('O9', 1110876543210 , 0.00),
('O10', 1110765432109 , 0.00),
('O11', 1110654321098 , 1.20),
('O12', 1110543210987 , 1.20),
('O13', 1110432109876 , 0.00),
('O14', 1110321098765 , 1.20),
('O15', 1110210987654 , 0.00),
('O16', 1110109876543 , 1.20),
('O17', 1110019283746 , 0.00),
('O18', 1110928374659 , 0.00),
('O19', 1110454656546 , 1.20),
('O19', 1110222222334 , 1.20),
('O20', 1110746583746 , 0.00),
('O21', 1110016592837 , 0.00),
('O22', 1110120910290 , 0.00),
('O23', 1110928392839 , 0.00),
('O24', 1110837467845 , 1.20),
('O25', 1110657465746 , 1.20),
('O26', 1110107283464 , 0.00),
('O27', 1110365802653 , 0.00),
('O28', 1110986467647 , 1.20),
('O29', 1110098702318 , 1.20),
('O30', 1110123413245 , 0.00),
('O31', 1110646709738 , 0.00),
('O32', 1110941419453 , 1.20),
('O33', 1110439453744 , 1.20),
('O34', 1110463253263 , 0.00),
('O35', 1110822344268 , 0.00),
('O36', 1110561232248 , 0.00),
('O37', 1110298374566 , 1.20),
('O38', 1110334455667 , 1.20),
('O39', 1110998877665 , 0.00),
('O40', 1110112233445 , 0.00),
('O41', 1110223344556 , 1.20),
('O42', 1110009988776 , 0.00),
('O43', 1110887766545 , 0.00),
('O43', 1110776655434 , 1.20),
('O44', 1110999888877 , 1.20),
('O45', 1110665544332 , 0.00),
('O46', 1110443352729 , 1.20),
('O47', 1110000098668 , 0.00),
('O48', 1110333474749 , 0.00),
('O49', 1110442221223 , 0.00),
('O50', 1110334488773 , 1.20),
('O51', 1110009272524 , 1.20),
('O52', 1110112222334 , 1.20),
('O53', 1110666677888 , 0.00),
('O54', 1110555666677 , 0.00),
('O55', 1110555332111 , 0.00),
('O56', 1110887665554 , 0.00),
('O57', 1110445667778 , 0.00),
('O58', 1110008866544 , 0.00),
('O58', 1110565676767 , 1.20),
('O58', 1110678657856 , 1.20),
('O59', 1110333332222 , 0.00),
('O60', 1110111222334 , 0.00),
('O61', 1110339876545 , 0.00),
('O62', 1110987645673 , 0.00),
('O63', 1110233423534 , 1.20),
('O64', 1110234435455 , 1.20),
('O65', 1110289777665 , 1.20),
('O66', 1110232435466 , 0.00),
('O67', 1110867887667 , 0.00),
('O68', 1110765867766 , 0.00),
('O69', 1110645646575 , 0.00),
('O70', 1110111112222 , 1.20),
('O71', 1110222222233 , 1.20),
('O72', 1110999999888 , 0.00),
('O73', 1110555555555 , 0.00),
('O74', 1110333322222 , 0.00),
('O75', 1110000000111 , 0.00),
('O76', 1110122222222 , 1.20),
('O77', 1110444444444 , 1.20),
('O78', 1110666666666 , 1.20),
('O79', 1110777778888 , 0.00),
('O80', 1110444444333 , 0.00),
('O81', 1110222211111 , 0.00),
('O82', 1110999999999 , 0.00),
('O83', 1110666777774 , 0.00),
('O84', 1110444444433 , 1.20),
('O85', 1110212121212 , 0.00),
('O86', 1110232223232 , 1.20),
('O87', 1110343434343 , 0.00),
('O88', 1110454545454 , 0.00),
('O89', 1110565656565 , 1.20),
('O90', 1110989898989 , 1.20),
('O91', 1110090900909 , 1.20),
('O92', 1110555556565 , 0.00),
('O93', 1110346455342 , 0.00);

INSERT INTO `card` (`card_number`, `titular_name`, `CVV`, `date_expiration` ) VALUES
(4556906634868762, 'Jose Silva', 123, '09-22'),
(4532596620807277, 'Beatriz Neto', 321, '10-23'),
(4716575352429375, 'Jo??o Cruz', 234, '11-22'),
(4024007127183514, 'Maria Jones', 345, '09-23'),
(4929039904245311, 'Pedro Calixto' , 456, '01-24'),
(4916518588314522, 'Albano Marques', 567, '11-22'),
(4485049560044789, 'Margarida Vasconcelos', 678, '12-24'),
(4916999138932163, 'Mariana Visconde', 789, '02-22'),
(4929629512858438, 'Carlos Gabriel', 890, '03-23'),
(4556910741474522, 'Fl??via Nunes', 900,  '04-24'),
(4916916410951141, 'Catarina Garcrz', 000, '05-22'),
(4485826493801348, 'Martim Manh??', 111, '06-23'),
(4485961513236546, 'Marta Fernandes', 222, '07-23'),
(4532940253837963, 'Luis Carvalho', 333, '08-24'),
(4532956011348143, 'Nuno Correia', 444, '09-22'),
(4916396412867662, 'Gabriela Silva', 555, '10-24'),
(4539559316605077, 'Carolina Serro', 666, '11-22'),
(4532363657870615, 'Tiago Bagorro', 777,  '12-24'),
(4716714665179456, 'Beatriz Pires', 888, '01-23'),
(4485129955293272, 'In??s Agostinho', 999, '02-22'),
(4024007133688068, 'Jo??o Pimenta', 011, '03-22'),
(4556662463223294, 'Roberto Peixeiro', 012, '04-24'),
(4556674259746792, 'Ricardo Guimar??es', 233, '05-23'),
(4091997024866997, 'Rute Guerra', 334,  '06-22'),
(4556655926151771, 'Diana Contantino', 445, '07-22'), 
(4224458411501051, 'Alice Vieira', 556, '08-24'),
(4532539364892444, 'Rui Roxinol', 667, '09-22'),
(4556618233331106, 'Joana Costa', 778, '10-23'), 
(4929238081475614, 'Cl??udio Costa', 889, '11-24'),
(4532102917730890, 'Catarina Couto', 994, '12-22'),
(4539966237055425, 'Cristiano Ronaldo', 566,  '01-22'),
(4929390091830922, 'Daniel Carreira', 434, '02-24'),
(4024007121909187, 'Diogo Almeida', 230, '03-23'),
(4916742152249837, 'D??bora Figeuira', 327, '04-24'),
(4539549569495367, 'Francisco Frad??o', 947,  '05-22'),
(4024007193704151, 'Beatriz Selid??nio', 746,  '06-23'),
(4539102604869590, 'Filipe Felizardo', 394, '07-24'),
(4556745657765285, 'Ana Fena', 917, '08-24'),
(4485964924215703, 'Rafael Gai??o', 937, '09-22'),
(4916800518803299, 'Rui Amaral', 468, '10-23'),
(4024007149330986, 'Gustavo Inglesias', 017, '11-24'),
(4532821115652180, 'Loredana Stefe', 104, '12-24'),
(4916740917118743, 'Mariana Serol', 187, '01-23'),
(4716060704376772, 'M??rio Soares', 826, '02-23'),
(4929273439870570, 'Gustavo Laranjeira', 196, '03-24'), 
(4916830539945688, 'Alecrim Meireles', 298,  '04-24'),
(4024007193958559, 'Hort??ncia Cabral', 284, '05-22'),
(4532409528322615, 'Constan??a Alexandre', 735,  '06-22'),
(4532932428845161, 'Valentina Dobrescu', 107, '07-22'),
(4916195848251487, 'Miguel Sequeira', 725, '08-23'),
(4929068169354906, 'Yuri Lambda', 037, '09-24'),
(4916898593073515, 'Rita Guerreira', 263, '10-23'),
(4916415480958144, 'Ana Mota', 285,  '11-23'),
(4532019775854978, 'Rute Marlene', 178,  '12-24'),
(4916205856286505, 'Angelico Milte', 143, '01-24'), 
(4929364262665433, 'Pedro Pedras', 140,  '02-23'),
(4485496901019915, 'Bia Barrocas', 645,  '03-23'),
(4024007185642237, 'Bernardo Paulo', 228, '04-24'),
(4024007179339980, 'Bernardina Baganha', 455, '05-23'),
(4539920764551983, 'Joana Brito', 451, '06-24'),
(4532394716626003, 'Carlos Ferreira', 857, '07-23'),
(4485226018823184, 'Diogo Dami??o', 983, '08-22'),
(4024007149205436, 'Jo??o Guedes', 354, '09-22'),
(4556502481620495, 'Rui Amaral', 452, '10-23'),
(4234209600395021, 'M??rio Soares', 210, '11-23'),
(4916724701494767, 'Beatriz Pires', 211, '12-24'),
(4610397849027093, 'Sara Silva', 112, '12-24'),
(4916635462937895, 'Ant??nio Pedras', 907, '01-22'),
(4532063216923026, 'Rui Amaral', 467, '02-22'),
(4539317145461943, 'Filipa Cabano', 345, '02-23'),
(4024007193071437, 'Ruben Ruas', 468, '03-24'),
(4539460079574099, 'Catarina Rato', 183, '04-24'),
(4532860739855209, 'Ana Silva', 135, '05-24'),
(4024007130728446, 'Maria Vargas', 567, '06-23'),
(4485852214775546, 'Beatriz Neto', 567, '06-24'),
(4485897516053993, 'Jo??o Trindade', 367, '07-22'),
(4916641098329531, 'M??rio Pires', 364, '08-22'),
(4077663671375561, 'Tiago Figueira', 163, '09-23'),
(4539002049361650, 'Tiago Valido', 465, '10-23'),
(4532212844131458, 'Paula Vicente', 876, '11-24');

INSERT INTO `payment` (`order_id`, `card_number`, `payment_datetime`) VALUES
('O1', 4556906634868762, '2021-01-30 03:59:34'),
('O2', 4556906634868762, '2019-02-22 15:13:21'),
('O3', 4532596620807277, '2019-02-14 10:24:41'),
('O4', 4716575352429375, '2019-06-01 14:05:11'),
('O5', 4024007127183514, '2018-12-28 00:17:12'),
('O6', 4929039904245311, '2019-03-09 13:25:16'),
('O7',  4532596620807277, '2019-03-06  18:19:32'), 
('O8', 4485049560044789, '2019-02-14 11:12:51'),
('O9',  4916999138932163, '2019-02-01 12:58:26'),
('O10',  4929629512858438, '2019-04-16 13:22:01'),
('O11',  4556910741474522, '2019-03-31 19:23:30'),
('O12',  4916916410951141, '2019-04-01 20:24:43'),
('O13',  4485826493801348, '2019-08-10 22:40:13'),
('O14',  4485961513236546, '2019-04-21 23:42:53'),
('O15',  4485961513236546, '2020-02-20 21:12:45'),
('O16',  4532940253837963, '2020-01-01 11:14:56'),
('O17',  4532956011348143, '2020-04-01 09:11:54'),
('O18',  4916396412867662, '2020-11-27 18:32:00'),
('O19',  4024007121909187, '2019-03-01 12:27:22'),
('O20',  4539559316605077, '2020-11-30 09:00:05'),
('O21',  4532363657870615, '2020-09-20 16:27:13'),
('O22',  4716714665179456, '2020-12-15 12:07:11'),
('O23',  4485129955293272, '2020-12-02 16:32:50'),
('O24',  4556662463223294, '2020-11-27 07:59:05'),
('O25',  4556674259746792, '2020-11-30 15:08:04'), 
('O26',  4091997024866997, '2021-11-01 13:35:22'),
('O27',  4556655926151771, '2021-08-06 12:13:59'),
('O28',  4224458411501051, '2019-05-26 06:09:16'),
('O29',  4532539364892444, '2019-02-09 10:12:17'),
('O30',  4556618233331106, '2020-02-02 12:24:11'),
('O31',  4929238081475614, '2019-12-31 14:58:14'),
('O32',  4532102917730890, '2020-06-01 02:37:31'),
('O33',  4539966237055425, '2020-02-28 08:11:45'),
('O34',  4929390091830922, '2020-09-30 15:19:19'),
('O35',  4024007121909187, '2020-10-23 19:47:14'),
('O36',  4916742152249837, '2021-11-26 20:31:01'),
('O37',  4539549569495367, '2021-12-01 15:39:22'),
('O38',  4539102604869590, '2021-11-01 16:18:31'),
('O39',  4556745657765285, '2021-01-26 21:25:54'),
('O40',  4485964924215703, '2021-03-29 14:47:43'),
('O41',  4916800518803299, '2021-04-03 18:22:49'),
('O42',  4024007149330986, '2021-02-01 13:48:54'),
('O43',  4532821115652180, '2021-04-27 01:18:11'),
('O44',  4916740917118743, '2021-07-10 23:03:28'),
('O45',  4916740917118743, '2020-12-31 22:27:52'),
('O46',  4929273439870570, '2021-10-20 16:11:43'),
('O47',  4916830539945688, '2021-03-01 10:17:19'),
('O48',  4024007193958559, '2021-02-14 09:17:43'),
('O49',  4532409528322615, '2019-12-15 07:49:12'),
('O50',  4532932428845161, '2019-12-10 09:14:41'),
('O51',  4532932428845161, '2020-11-30 11:27:45'),
('O52',  4916195848251487, '2021-11-26 17:38:15'),
('O53',  4929068169354906, '2019-02-10 09:14:19'),
('O54',  4916898593073515, '2019-12-27 14:28:24'),
('O55',  4916415480958144, '2020-01-20 20:52:51'),
('O56',  4532019775854978, '2020-06-01 14:35:12'),
('O57',  4916205856286505, '2020-10-01 08:04:00'),
('O58',  4556906634868762, '2019-09-06 14:07:11'),
('O59',  4556906634868762, '2020-11-07 15:04:13'),
('O60',  4556906634868762, '2020-11-03 12:17:49'),
('O61',  4556906634868762, '2021-11-09 13:09:12'),
('O62',  4485496901019915, '2021-01-01 12:35:22'),
('O63',  4916518588314522, '2021-04-30 09:12:47'),
('O64',  4916518588314522, '2020-08-03 06:25:12'),
('O65',  4024007185642237, '2021-01-21 11:03:13'),
('O66',  4024007179339980, '2021-05-04 08:13:42'),
('O67',  4539920764551983, '2021-05-01 19:07:26'),
('O68',  4532394716626003, '2021-03-15 12:16:14'),
('O69',  4485226018823184, '2021-07-07 08:05:35'),
('O70',  4024007149205436, '2021-04-05 08:25:46'),
('O71',  4556502481620495, '2020-11-20 12:08:20'),
('O72',  4024007193704151, '2021-02-14 05:49:32'),
('O73',  4024007193704151, '2021-01-27 04:06:19'),
('O74',  4234209600395021, '2021-03-03 15:35:18'),
('O75',  4916724701494767, '2021-01-28 03:12:58'),
('O76',  4610397849027093, '2019-02-14 13:37:15'),
('O77',  4916635462937895, '2018-11-10 09:29:51'),
('O78',  4532063216923026, '2018-09-30 15:02:04'),
('O79',  4539317145461943, '2019-01-05 00:06:05'),
('O80',  4539460079574099, '2019-04-09 23:48:05'),
('O81',  4024007193071437, '2019-02-23 10:14:14'),
('O82',  4532860739855209, '2019-02-19 19:22:18'),
('O83',  4024007130728446, '2019-08-09 07:41:29'),
('O84',  4485852214775546, '2019-09-03 13:43:15'),
('O85',  4485897516053993, '2019-08-30 09:12:09'),
('O86',  4916641098329531, '2020-12-15 14:44:13'),
('O87',  4077663671375561, '2020-09-17 12:43:54'),
('O88',  4539002049361650, '2020-11-27 15:59:46'),
('O89',  4532212844131458, '2020-04-02 12:17:42'),
('O90',  4024007133688068, '2020-10-19 14:37:52'),
('O91',  4024007133688068, '2020-09-13 13:26:52'),
('O92',  4532596620807277, '2021-09-22 23:56:12'),
('O93',  4916740917118743, '2019-04-11 10:17:12');

-- -----------------------------------------------------
-- UPDATES and new Check
-- -----------------------------------------------------

-- Note: IVA is 6% for 2020/2021 and 13% for years before 2020
UPDATE `order_`
SET tax_rate = 0.06
WHERE YEAR(order_datetime) BETWEEN 2020 AND 2021;

UPDATE `order_`
SET tax_rate = 0.13
WHERE YEAR(order_datetime) < 2020;

-- Note: Does the calculations for the total amount that the customer has to pay
UPDATE `order_` AS o
SET o.total = (SELECT Get_Total_Table.Total 
			   FROM (SELECT o_i.order_id AS Order_ID, 
							(( SUM(z.ticket_unit_price) + (o.quantity * o_i.insurance)) - (SUM(z.ticket_unit_price) * p.promotion_rate)) AS Total
					 FROM zone AS z
					 JOIN seat AS s ON z.zone_id = s.zone_id
					 JOIN ticket AS t ON s.seat_id = t.seat_id
                     JOIN order_items AS o_i ON t.bar_code = o_i.bar_code
                     JOIN order_ AS o ON o_i.order_id = o.order_id
                     JOIN promotion AS p ON o.promotion_id = p.promotion_id
                     GROUP BY o_i.order_id) AS Get_Total_Table			
				WHERE o.order_id = Get_Total_Table.Order_ID
               );

ALTER TABLE `order_`
ADD CONSTRAINT `order_quantity_check`
	CHECK (quantity > 0),
ADD CONSTRAINT `order_total_check`
	CHECK (total > 0);
	
-- -----------------------------------------------------
-- View for the Head and Totals
-- -----------------------------------------------------

DROP VIEW IF EXISTS Invoice_Head_and_Totals ; 
CREATE VIEW Invoice_Head_and_Totals AS
SELECT DISTINCT SUBSTRING(o.order_id, 2, 3) AS InvoiceNumber, 
				DATE_FORMAT(p.payment_datetime, '%Y/%m/%d') AS 'Date of Issue',
				c.name AS 'Customer Name', 
                lc.address AS 'Customer Address', 
                CONCAT(lc.city, ', ', lc.district, ', Portugal') AS 'City, District and Country', 
				lc.zip_code AS 'Zip Code', 
                t.company_name AS 'Company Name', 
                'Avenida Ivone Silva' AS 'Company Address', 
                t.company_phonenumber AS 'Company PhoneNumber', 
				'ticketbuddy@ticketbuddy.pt' AS 'Company Email',
                t.company_website AS 'Company Website', 
                ROUND(((o.total + (o.total * pr.promotion_rate)) - (o.quantity * o_i.insurance)) / (1 + o.tax_rate), 2) AS "Total w/o Tax", 
                ROUND((((o.total + (o.total * pr.promotion_rate)) - (o.quantity * o_i.insurance)) / (1 + o.tax_rate)) * o.tax_rate, 2) AS 'Ticket Tax Value', 
                (o.quantity * o_i.insurance) AS Insurance,                 
				ROUND(o.total + (o.total * pr.promotion_rate), 1) AS 'Subtotal (Total w/ Tax)',
				ROUND(o.total * pr.promotion_rate, 2) AS Discount,
                o.total AS Total
FROM payment AS p
JOIN order_ AS o ON p.order_id = o.order_id
LEFT JOIN promotion as pr ON o.promotion_id = pr.promotion_id
JOIN customer AS c ON o.customer_id = c.customer_id
JOIN location AS lc ON c.location_id = lc.location_id
JOIN order_items AS o_i ON o.order_id = o_i.order_id
JOIN ticket AS t ON o_i.bar_code = t.bar_code
JOIN seat AS s ON t.seat_id = s.seat_id
JOIN zone AS z ON s.zone_id = z.zone_id
GROUP BY o.order_id;

/*
-- Invoice of an Order with 2 tickets with 2 distinct events (w/ insurance and w/o Discount)
SELECT * FROM Invoice_Head_and_Totals
WHERE InvoiceNumber = '19';
 
-- Invoice of an Order with 2 tickets of the same session of an Event (w/o Insurance and Discount)
SELECT * FROM Invoice_Head_and_Totals
WHERE InvoiceNumber = '1';

-- Invoice of an Order with 1 ticket (w/ insurance and Discount)
SELECT * FROM Invoice_Head_and_Totals
WHERE InvoiceNumber = '14';
*/

-- -----------------------------------------------------
-- View for the Details
-- -----------------------------------------------------
DROP VIEW IF EXISTS Invoice_Details ; 
CREATE VIEW Invoice_Details AS 
SELECT SUBSTRING(o.order_id, 2, 3) AS InvoiceNumber,
       e.event_description AS 'Description', 
       SUM(ROUND(o.quantity/o.quantity, 0)) AS Quantity, 
       ROUND(z.ticket_unit_price / (1 + o.tax_rate), 2) AS "Ticket Unit Price w/o Tax", 
       ROUND((SUM(ROUND(o.quantity/o.quantity, 0))) * (z.ticket_unit_price / (1 + o.tax_rate)), 2) AS "Total w/o Tax", 
       o.tax_rate AS 'Ticket Tax Rate',
       o_i.insurance AS Insurance,   
       ROUND((SUM(ROUND(o.quantity/o.quantity, 0))) * z.ticket_unit_price + (SUM(ROUND(o.quantity/o.quantity, 0)) * o_i.insurance), 2) AS 'Subtotal (Total w/ Tax)',
       ROUND(o.total * p.promotion_rate, 2) AS Discount,
	   (ROUND((SUM(ROUND(o.quantity/o.quantity, 0))) * ((z.ticket_unit_price / (1 + o.tax_rate)) * (1 + o.tax_rate)), 2) - (ROUND(o.total * p.promotion_rate, 2)) + (SUM(ROUND(o.quantity/o.quantity, 0)) * o_i.insurance)) AS Total       
FROM event AS e
LEFT JOIN session AS ss ON e.event_id = ss.event_id
JOIN zone AS z ON ss.session_id = z.session_id
LEFT JOIN seat AS s ON z.zone_id = s.zone_id
LEFT JOIN ticket AS t ON s.seat_id = t.seat_id
LEFT JOIN order_items AS o_i ON t.bar_code = o_i.bar_code
LEFT JOIN order_ AS o ON o_i.order_id = o.order_id
LEFT JOIN promotion AS p ON o.promotion_id = p.promotion_id
GROUP BY SUBSTRING(o.order_id, 2, 3), e.event_description ;

/*
-- Invoice of an Order with 2 tickets with 2 distinct events (w/ insurance and w/o Discount)
SELECT * FROM Invoice_Details
WHERE InvoiceNumber = '19';
 
-- Invoice of an Order with 2 tickets of the same session of an Event (w/o Insurance and Discount)
SELECT * FROM Invoice_Details
WHERE InvoiceNumber = '1';

-- Invoice of an Order with 1 ticket (w/ insurance and Discount)
SELECT * FROM Invoice_Details
WHERE InvoiceNumber = '14';
*/

-- -----------------------------------------------------
-- Testing Trigger `Update_session_date`
-- -----------------------------------------------------
/*
SELECT *
FROM session
LIMIT 10;

UPDATE session 
SET session_date = '2019-06-06'
WHERE session_id = 'SS1';

UPDATE session 
SET session_date = '2019-02-15'
WHERE session_id = 'SS13' 
OR session_id = 'SS14';

SELECT *
FROM session
WHERE session_date = '2019-06-06' 
OR session_date = '2019-02-15';

SELECT *
FROM log;
*/

-- -----------------------------------------------------
-- Testing Trigger `Order_Quantity_Update`
-- -----------------------------------------------------
/*
SELECT *
FROM order_;
*/
                            
-- -----------------------------------------------------
-- Testing Trigger `Info_Customer_Update`
-- -----------------------------------------------------
/*
SELECT *
FROM ticket;
*/
