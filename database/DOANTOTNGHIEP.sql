-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: diabetes_project
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `conditions_dictionary`
--

DROP TABLE IF EXISTS `conditions_dictionary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conditions_dictionary` (
  `id` int NOT NULL AUTO_INCREMENT,
  `condition_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `condition_name` (`condition_name`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conditions_dictionary`
--

LOCK TABLES `conditions_dictionary` WRITE;
/*!40000 ALTER TABLE `conditions_dictionary` DISABLE KEYS */;
INSERT INTO `conditions_dictionary` VALUES (8,'Bệnh lý bàn chân do tiểu đường (Lở loét, nhiễm trùng)'),(13,'Béo phì / Thừa cân'),(5,'Biến chứng suy thận (Bệnh thận do tiểu đường)'),(7,'Biến chứng thần kinh ngoại biên (Tê bì tay chân)'),(6,'Biến chứng võng mạc (Mờ mắt do tiểu đường)'),(9,'Cao huyết áp (Tăng huyết áp)'),(11,'Gan nhiễm mỡ'),(14,'Mất thính lực'),(15,'Mất trí nhớ'),(16,'Ngưng thở khi ngủ'),(17,'Rối loạn cương dương'),(10,'Rối loạn mỡ máu (Mỡ máu cao / Tăng lipid máu)'),(12,'Suy tim'),(4,'Tiền tiểu đường'),(1,'Tiểu đường loại 1'),(2,'Tiểu đường loại 2'),(3,'Tiểu đường thai kỳ');
/*!40000 ALTER TABLE `conditions_dictionary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exercise_dictionary`
--

DROP TABLE IF EXISTS `exercise_dictionary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercise_dictionary` (
  `id` int NOT NULL AUTO_INCREMENT,
  `exercise_name` varchar(100) NOT NULL,
  `calories_per_30_minutes` int NOT NULL,
  `img_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `exercise_name` (`exercise_name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercise_dictionary`
--

LOCK TABLES `exercise_dictionary` WRITE;
/*!40000 ALTER TABLE `exercise_dictionary` DISABLE KEYS */;
INSERT INTO `exercise_dictionary` VALUES (1,'Nhảy dây',330,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/NhayDay_st79k5'),(2,'Bơi lội',240,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BoiLoi_iuhoko'),(3,'Thể dục nhịp điệu',180,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/TheDucNhipDieu_cilt5i'),(4,'Đạp xe',210,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/DapXe_nm2dlv'),(5,'Tập tạ hay kháng lực',150,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/TapTaHayKhangLuc_ma4saq'),(6,'Khiêu vũ',150,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/KhieuVu_mmr8vv'),(7,'Đi bộ',120,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/DiBo_fh2njq'),(8,'Làm việc nhà',90,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/LamViecNha_gs7md1');
/*!40000 ALTER TABLE `exercise_dictionary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exercise_logs`
--

DROP TABLE IF EXISTS `exercise_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercise_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `exercise_def_id` int NOT NULL,
  `duration_minutes` int NOT NULL DEFAULT '30',
  `logged_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_exercise_user` (`user_id`),
  KEY `fk_exercise_def` (`exercise_def_id`),
  CONSTRAINT `fk_exercise_def` FOREIGN KEY (`exercise_def_id`) REFERENCES `exercise_dictionary` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_exercise_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercise_logs`
--

LOCK TABLES `exercise_logs` WRITE;
/*!40000 ALTER TABLE `exercise_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `exercise_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `food_dictionary`
--

DROP TABLE IF EXISTS `food_dictionary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_dictionary` (
  `id` int NOT NULL AUTO_INCREMENT,
  `meal_name` varchar(150) NOT NULL,
  `meal_type` varchar(10) NOT NULL,
  `calories` int NOT NULL,
  `img_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `meal_name` (`meal_name`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `food_dictionary`
--

LOCK TABLES `food_dictionary` WRITE;
/*!40000 ALTER TABLE `food_dictionary` DISABLE KEYS */;
INSERT INTO `food_dictionary` VALUES (1,'Cháo yến mạch và ức gà','Bữa sáng',290,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ChaoYenMachVaUcGa_l79loc'),(2,'Trứng luộc','Bữa sáng',78,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/TrungLuoc_iksd2b'),(3,'Bánh mì kẹp đậu ăn kiêng','Bữa sáng',210,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BanhMiKepDauAnKieng_mqrbzw'),(4,'Cháo yến mạch thịt băm','Bữa sáng',320,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ChaoYenMachThitBam_oaslsp'),(5,'Trứng cuộn rau bina','Bữa sáng',145,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/TrungCuonRauBina_w1rzsk'),(6,'Yến mạch ngâm sữa','Bữa sáng',260,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/YenMachNgamSua_psnxlw'),(7,'Mâm xôi việt quất','Bữa sáng',65,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/MamXoiVietQuat_tzwhsi'),(8,'Bánh mì kẹp bơ quả','Bữa sáng',240,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BanhBiKepBoQua_ne38gh'),(9,'Bánh mì kẹp bơ đậu phộng','Bữa sáng',280,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BanhMiKepBoDauPhong_umlwda'),(10,'Sữa béo ấm','Bữa sáng',150,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SuaBeoAm_ggfsdp'),(11,'Quả táo','Bữa sáng',52,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaTao_sur1lh'),(12,'Cơm ngô đậu Hà Lan','Bữa trưa',210,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ComNgoDauHaLan_dafjbh'),(13,'Thịt bò xào súp lơ','Bữa trưa',265,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ThitBoXaoSupLo_dwcmc7'),(14,'Canh bắp cải nấu thịt băm','Bữa trưa',95,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CanhBapCaiNauThitBam_znydsh'),(15,'Khoai tây nướng','Bữa trưa',160,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/KhoaiTayNuong_hqnfcu'),(16,'Hải sản hấp sả','Bữa trưa',120,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/HaiSanHapSa_z9fzbo'),(17,'Măng tây xào giá đỗ','Bữa trưa',75,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/MangTayXaoGiaDo_ney4ql'),(18,'Quả lê','Bữa trưa',57,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaLe_vpv7fr'),(19,'Gà áp chảo xé phay','Bữa trưa',185,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/GaApChaoXePhay_t228rk'),(20,'Su hào củ cải đường luộc','Bữa trưa',45,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SuHaoCuCaiDuongLuoc_thmdh8'),(21,'Đậu phụ nướng sả tỏi','Bữa trưa',110,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/DauPhuNuongSaToi_n7je6s'),(22,'Salad trộn sốt bơ quả','Bữa trưa',135,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SaladTronSotBoQua_zq3mv3'),(23,'Cơm lúa mạch','Bữa trưa',190,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ComLuaMach_knxnv1'),(24,'Hải sản xào ớt chuông','Bữa trưa',165,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/HaiSanXaoOtChuong_mgzxke'),(25,'Canh củ cải đường','Bữa trưa',40,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CanhCuCaiDuong_dexrev'),(26,'Cá nạc sốt cà chua tươi','Bữa trưa',150,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CaNacSotCaChuaTuoi_clgspe'),(27,'Đậu bắp luộc','Bữa trưa',33,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/DauBapLuoc_czzdcn'),(28,'Khoai lang luộc','Bữa tối',115,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/KhoaiLangLuoc_h6lz8x'),(29,'Cá hồi sốt bơ tỏi','Bữa tối',280,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CaHoiSotBoToi_b6t1ov'),(30,'Sắn luộc','Bữa tối',160,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SanLuoc_imitmc'),(31,'Thịt bò né áp chảo','Bữa tối',310,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ThitBoNeApChao_sc5zc2'),(32,'Bí ngòi nướng dầu oliu','Bữa tối',85,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BiNgoiNuongDauOLiu_r8vjbp'),(33,'Quả bưởi','Bữa tối',42,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaBuoi_yqk3su'),(34,'Cá nướng giấy bạc','Bữa tối',140,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CaNuongGiayBac_k93qs4'),(35,'Sốt táo không đường','Bữa tối',60,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SotTaoKhongDuong_yhcba2'),(36,'Canh khoai mỡ','Bữa tối',120,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CanhKhoaiMo_ssvbzk'),(37,'Thịt heo cuộn rau và bánh tráng','Bữa tối',245,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ThitHeoCuonRauVaBanhTrang_qgvblg'),(38,'Quả nho','Bữa tối',67,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaNho_va4g5b'),(39,'Cơm tinh bột','Bữa tối',130,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ComTinhBot_iy147v'),(40,'Gà sốt bơ tỏi','Bữa tối',295,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/GaSotBoToi_tznqmh'),(41,'Súp lơ luộc','Bữa tối',34,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SupLoLuoc_ycz3yf'),(42,'Quả cam','Bữa tối',47,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaCam_hufnzk'),(43,'Canh sườn heo nạc nấu rau củ','Bữa tối',180,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CanhSuonHeoNacNauRauCu_lmscm5'),(44,'Bánh mì quét bơ đậu phộng','Ăn nhẹ',190,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BanhMiQuetBoDauPhong_p46yn8'),(45,'Hạt tổng hợp','Ăn nhẹ',165,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/HatTongHop_kyhdih'),(46,'Quả dưa miếng','Ăn nhẹ',46,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaDuaMieng_udc0i1'),(47,'Sữa chua ít béo','Ăn nhẹ',80,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SuaChuaItBeo_ae0fsw'),(48,'Quả chuối','Ăn nhẹ',89,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaChuoi_wbnmrb'),(49,'Bánh mì nguyên cám','Ăn nhẹ',65,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BanhMiNguyenCam_zprcuz'),(50,'Quả dâu tây','Ăn nhẹ',32,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaDauTay_uipf2z'),(51,'Quả đào','Ăn nhẹ',39,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaDao_ivdeeo'),(52,'Sữa chua ít béo và dâu tây','Ăn nhẹ',110,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SuaChuaItBeoVaDauTay_moetmw'),(53,'Bơ tươi rắc hạt','Ăn nhẹ',185,'https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BoTuoiRacHat_lp8wtg');
/*!40000 ALTER TABLE `food_dictionary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `food_log_details`
--

DROP TABLE IF EXISTS `food_log_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_log_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `food_log_id` int NOT NULL,
  `food_dictionary_id` int DEFAULT NULL,
  `carb_g` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_details_master` (`food_log_id`),
  KEY `fk_food_log_details_dictionary` (`food_dictionary_id`),
  CONSTRAINT `fk_details_master` FOREIGN KEY (`food_log_id`) REFERENCES `food_logs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_food_log_details_dictionary` FOREIGN KEY (`food_dictionary_id`) REFERENCES `food_dictionary` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `food_log_details`
--

LOCK TABLES `food_log_details` WRITE;
/*!40000 ALTER TABLE `food_log_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `food_log_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `food_logs`
--

DROP TABLE IF EXISTS `food_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `carb_accumulated` int DEFAULT '0',
  `logged_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_food_user` (`user_id`),
  CONSTRAINT `fk_food_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `food_logs`
--

LOCK TABLES `food_logs` WRITE;
/*!40000 ALTER TABLE `food_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `food_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `health_metrics_logs`
--

DROP TABLE IF EXISTS `health_metrics_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `health_metrics_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `blood_sugar` int NOT NULL,
  `unit` varchar(10) NOT NULL,
  `systolic_bp` int NOT NULL,
  `diastolic_bp` int NOT NULL,
  `heart_rate` int NOT NULL,
  `logged_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_blood_sugar_user` (`user_id`),
  CONSTRAINT `fk_blood_sugar_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `health_metrics_logs`
--

LOCK TABLES `health_metrics_logs` WRITE;
/*!40000 ALTER TABLE `health_metrics_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `health_metrics_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medication_dictionary`
--

DROP TABLE IF EXISTS `medication_dictionary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medication_dictionary` (
  `id` int NOT NULL AUTO_INCREMENT,
  `medication_name` varchar(150) NOT NULL,
  `medication_category` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `medication_name` (`medication_name`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medication_dictionary`
--

LOCK TABLES `medication_dictionary` WRITE;
/*!40000 ALTER TABLE `medication_dictionary` DISABLE KEYS */;
INSERT INTO `medication_dictionary` VALUES (1,'Insulin Actrapid (Insulin tác dụng nhanh)','Thuốc tiêm Insulin định kỳ'),(2,'Insulin Lantus SoloStar (Insulin nền kéo dài)','Thuốc tiêm Insulin định kỳ'),(3,'Vaxigrip Tetra - Pháp (Vaccine Cúm hàng năm)','Vaccine cúm dự phòng'),(4,'Prevenar 13 - Mỹ  (Vaccine Phế cầu khuẩn)','Vaccine phế cầu dự phòng'),(5,'NovoRapid / NovoLog (Insulin Aspart)','Thuốc tiêm Insulin bữa ăn (Siêu nhanh)'),(6,'Humalog (Insulin Lispro)','Thuốc tiêm Insulin bữa ăn (Siêu nhanh)'),(7,'Apidra (Insulin Glulisine)','Thuốc tiêm Insulin bữa ăn (Siêu nhanh)'),(8,'Fiasp (Insulin Aspart thế hệ mới)','Thuốc tiêm Insulin bữa ăn (Cực nhanh - Tiêm trong/sau ăn)'),(13,'Rybelsus (Semaglutide)','Thuốc viên hạ đường huyết - Nhóm chủ vận GLP-1');
/*!40000 ALTER TABLE `medication_dictionary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medication_logs`
--

DROP TABLE IF EXISTS `medication_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medication_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `medication_def_id` int NOT NULL,
  `reminder_id` int DEFAULT NULL,
  `dosage` varchar(50) NOT NULL,
  `logged_at` datetime NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'Chưa uống',
  `note` varchar(300) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_medication_user` (`user_id`),
  KEY `fk_medication_def` (`medication_def_id`),
  KEY `fk_medication_log_reminder` (`reminder_id`),
  CONSTRAINT `fk_medication_def` FOREIGN KEY (`medication_def_id`) REFERENCES `medication_dictionary` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_medication_log_reminder` FOREIGN KEY (`reminder_id`) REFERENCES `reminders` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_medication_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medication_logs`
--

LOCK TABLES `medication_logs` WRITE;
/*!40000 ALTER TABLE `medication_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `medication_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `otp_codes`
--

DROP TABLE IF EXISTS `otp_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `otp_codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `otp_code` varchar(6) NOT NULL,
  `is_used` smallint DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `otp_codes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otp_codes`
--

LOCK TABLES `otp_codes` WRITE;
/*!40000 ALTER TABLE `otp_codes` DISABLE KEYS */;
INSERT INTO `otp_codes` VALUES (1,1,'584121',1,'2026-05-29 06:16:59','2026-05-29 06:21:59');
/*!40000 ALTER TABLE `otp_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient_conditions`
--

DROP TABLE IF EXISTS `patient_conditions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_conditions` (
  `patient_profile_id` int NOT NULL,
  `condition_id` int NOT NULL,
  PRIMARY KEY (`patient_profile_id`,`condition_id`),
  KEY `fk_patient_condition_def` (`condition_id`),
  CONSTRAINT `fk_patient_condition_def` FOREIGN KEY (`condition_id`) REFERENCES `conditions_dictionary` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_patient_condition_profile` FOREIGN KEY (`patient_profile_id`) REFERENCES `patient_profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_conditions`
--

LOCK TABLES `patient_conditions` WRITE;
/*!40000 ALTER TABLE `patient_conditions` DISABLE KEYS */;
/*!40000 ALTER TABLE `patient_conditions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient_profiles`
--

DROP TABLE IF EXISTS `patient_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_profiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `diabetes_type` varchar(20) NOT NULL,
  `target_low` int DEFAULT '70',
  `target_high` int DEFAULT '180',
  `weight` int DEFAULT NULL,
  `height` int DEFAULT NULL,
  `age` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_profiles_user` (`user_id`),
  CONSTRAINT `fk_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_profiles`
--

LOCK TABLES `patient_profiles` WRITE;
/*!40000 ALTER TABLE `patient_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `patient_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient_symptoms`
--

DROP TABLE IF EXISTS `patient_symptoms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_symptoms` (
  `patient_profile_id` int NOT NULL,
  `symptom_id` int NOT NULL,
  PRIMARY KEY (`patient_profile_id`,`symptom_id`),
  KEY `fk_patient_symptom_def` (`symptom_id`),
  CONSTRAINT `fk_patient_symptom_def` FOREIGN KEY (`symptom_id`) REFERENCES `symptoms_dictionary` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_patient_symptom_profile` FOREIGN KEY (`patient_profile_id`) REFERENCES `patient_profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_symptoms`
--

LOCK TABLES `patient_symptoms` WRITE;
/*!40000 ALTER TABLE `patient_symptoms` DISABLE KEYS */;
/*!40000 ALTER TABLE `patient_symptoms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reminder_logs`
--

DROP TABLE IF EXISTS `reminder_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reminder_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `reminder_id` int NOT NULL,
  `is_consume_medicine` tinyint DEFAULT '0',
  `status_updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_logs_reminder_parent` (`reminder_id`),
  CONSTRAINT `fk_logs_reminder_parent` FOREIGN KEY (`reminder_id`) REFERENCES `reminders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reminder_logs`
--

LOCK TABLES `reminder_logs` WRITE;
/*!40000 ALTER TABLE `reminder_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `reminder_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reminders`
--

DROP TABLE IF EXISTS `reminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reminders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `rem_def_id` int DEFAULT NULL,
  `title` varchar(300) NOT NULL,
  `reminder_time` time NOT NULL,
  `is_active` tinyint DEFAULT '1',
  `is_deleted` tinyint DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_reminders_user` (`user_id`),
  CONSTRAINT `fk_reminders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reminders`
--

LOCK TABLES `reminders` WRITE;
/*!40000 ALTER TABLE `reminders` DISABLE KEYS */;
/*!40000 ALTER TABLE `reminders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `symptoms_dictionary`
--

DROP TABLE IF EXISTS `symptoms_dictionary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `symptoms_dictionary` (
  `id` int NOT NULL AUTO_INCREMENT,
  `symptom_name` varchar(150) NOT NULL,
  `symptoms_type` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `symptom_name` (`symptom_name`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `symptoms_dictionary`
--

LOCK TABLES `symptoms_dictionary` WRITE;
/*!40000 ALTER TABLE `symptoms_dictionary` DISABLE KEYS */;
INSERT INTO `symptoms_dictionary` VALUES (1,'Da khô','Tăng đường huyết'),(2,'Đi tiểu thường xuyên','Tăng đường huyết'),(3,'Cảm thấy đói (Ăn nhiều)','Tăng đường huyết'),(4,'Mờ mắt','Tăng đường huyết'),(5,'Vết thương lâu lành / lở loét','Tăng đường huyết'),(6,'Khát nước dữ dội','Tăng đường huyết'),(7,'Cảm thấy buồn ngủ, lờ đờ','Tăng đường huyết'),(8,'Cảm thấy run rẩy','Hạ đường huyết cấp tính'),(9,'Tim đập nhanh','Hạ đường huyết cấp tính'),(10,'Đổ mồ hôi (Mồ hôi lạnh)','Hạ đường huyết cấp tính'),(11,'Dễ cáu gắt, tâm trạng thay đổi','Hạ đường huyết cấp tính'),(12,'Suy nhược cơ thể','Hạ đường huyết cấp tính'),(13,'Mệt mỏi','Hạ đường huyết cấp tính'),(14,'Chóng mặt','Hạ đường huyết cấp tính'),(15,'Lo lắng, bồn chồn','Hạ đường huyết cấp tính'),(16,'Đói cồn cào','Hạ đường huyết cấp tính'),(17,'Đau đầu','Hạ đường huyết cấp tính');
/*!40000 ALTER TABLE `symptoms_dictionary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `DOB` datetime NOT NULL,
  `hashed_password` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'tin1234@gmail.com','2026-06-17 00:00:00','$2b$12$Oo4a9VBZdAvUIFd7guWdB./wSWp2MqjCSR2wMRNHdh3SvOG2WJlEG','Trọng Tín','2026-05-29 06:15:56');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-29 15:23:10
