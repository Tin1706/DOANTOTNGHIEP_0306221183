CREATE DATABASE  IF NOT EXISTS `diabetes_project` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `diabetes_project`;
-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: diabetes_project
-- ------------------------------------------------------
-- Server version	8.0.41

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
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conditions_dictionary`
--

LOCK TABLES `conditions_dictionary` WRITE;
/*!40000 ALTER TABLE `conditions_dictionary` DISABLE KEYS */;
INSERT INTO `conditions_dictionary` VALUES (8,'Bệnh lý bàn chân do tiểu đường (Lở loét, nhiễm trùng)'),(13,'Bệnh tim mạch vành'),(17,'Béo phì / Thừa cân'),(5,'Biến chứng suy thận (Bệnh thận do tiểu đường)'),(7,'Biến chứng thần kinh ngoại biên (Tê bì tay chân)'),(6,'Biến chứng võng mạc (Mờ mắt do tiểu đường)'),(9,'Cao huyết áp (Tăng huyết áp)'),(12,'Gan nhiễm mỡ'),(24,'Gút (Gout)'),(20,'Mất thính lực'),(19,'Mất trí nhớ'),(21,'Ngưng thở khi ngủ'),(22,'Rối loạn cương dương'),(10,'Rối loạn mỡ máu (Mỡ máu cao / Tăng lipid máu)'),(14,'Suy tim'),(4,'Tiền tiểu đường'),(1,'Tiểu đường Loại 1'),(2,'Tiểu đường Loại 2'),(3,'Tiểu đường thai kỳ');
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
  `exercise_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `img_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `calories_30_minutes` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `exercise_name` (`exercise_name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercise_dictionary`
--

LOCK TABLES `exercise_dictionary` WRITE;
/*!40000 ALTER TABLE `exercise_dictionary` DISABLE KEYS */;
INSERT INTO `exercise_dictionary` VALUES (1,'Nhảy dây','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/NhayDay_st79k5',330),(2,'Bơi lội','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BoiLoi_iuhoko',240),(3,'Thể dục nhịp điệu','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/TheDucNhipDieu_cilt5i',180),(4,'Đạp xe','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/DapXe_nm2dlv',210),(5,'Tập tạ hay kháng lực','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/TapTaHayKhangLuc_ma4saq',150),(6,'Khiêu vũ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/KhieuVu_mmr8vv',150),(7,'Đi bộ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/DiBo_fh2njq',120),(8,'Làm việc nhà','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/LamViecNha_gs7md1',90);
/*!40000 ALTER TABLE `exercise_dictionary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `food_dictionary`
--

DROP TABLE IF EXISTS `food_dictionary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_dictionary` (
  `id` int NOT NULL AUTO_INCREMENT,
  `meal_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `meal_type` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `img_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `calories` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `meal_name` (`meal_name`)
) ENGINE=InnoDB AUTO_INCREMENT=160 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `food_dictionary`
--

LOCK TABLES `food_dictionary` WRITE;
/*!40000 ALTER TABLE `food_dictionary` DISABLE KEYS */;
INSERT INTO `food_dictionary` VALUES (1,'Cháo yến mạch và ức gà','Sáng','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ChaoYenMachVaUcGa_l79loc',290),(2,'Trứng luộc','Sáng','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/TrungLuoc_iksd2b',78),(3,'Bánh mì kẹp đậu ăn kiêng','Sáng','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BanhMiKepDauAnKieng_mqrbzw',210),(4,'Cháo yến mạch thịt băm','Sáng','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ChaoYenMachThitBam_oaslsp',320),(5,'Trứng cuộn rau bina','Sáng','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/TrungCuonRauBina_w1rzsk',145),(6,'Yến mạch ngâm sữa','Sáng','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/YenMachNgamSua_psnxlw',260),(7,'Mâm xôi việt quất','Sáng','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/MamXoiVietQuat_tzwhsi',65),(8,'Bánh mì kẹp bơ quả','Sáng','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BanhBiKepBoQua_ne38gh',240),(9,'Bánh mì kẹp bơ đậu phộng','Sáng','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BanhMiKepBoDauPhong_umlwda',280),(10,'Sữa béo ấm','Sáng','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SuaBeoAm_ggfsdp',150),(11,'Quả táo','Sáng','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaTao_sur1lh',52),(12,'Cơm ngô đậu Hà Lan','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ComNgoDauHaLan_dafjbh',210),(13,'Thịt bò xào súp lơ','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ThitBoXaoSupLo_dwcmc7',265),(14,'Canh bắp cải nấu thịt băm','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CanhBapCaiNauThitBam_znydsh',95),(15,'Khoai tây nướng','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/KhoaiTayNuong_hqnfcu',160),(16,'Hải sản hấp sả','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/HaiSanHapSa_z9fzbo',120),(17,'Măng tây xào giá đỗ','Trưa ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/MangTayXaoGiaDo_ney4ql',75),(18,'Quả lê','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaLe_vpv7fr',57),(19,'Gà áp chảo xé phay','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/GaApChaoXePhay_t228rk',185),(20,'Su hào củ cải đường luộc','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SuHaoCuCaiDuongLuoc_thmdh8',45),(21,'Đậu phụ nướng sả tỏi','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/DauPhuNuongSaToi_n7je6s',110),(22,'Salad trộn sốt bơ quả','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SaladTronSotBoQua_zq3mv3',135),(23,'Cơm lúa mạch','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ComLuaMach_knxnv1',190),(24,'Hải sản xào ớt chuông','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/HaiSanXaoOtChuong_mgzxke',165),(25,'Canh củ cải đường','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CanhCuCaiDuong_dexrev',40),(26,'Cá nạc sốt cà chua tươi','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CaNacSotCaChuaTuoi_clgspe',150),(27,'Đậu bắp luộc','Trưa','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/DauBapLuoc_czzdcn',33),(28,'Khoai lang luộc','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/KhoaiLangLuoc_h6lz8x',115),(29,'Cá hồi sốt bơ tỏi','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CaHoiSotBoToi_b6t1ov',280),(30,'Sắn luộc','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SanLuoc_imitmc',160),(31,'Thịt bò né áp chảo','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ThitBoNeApChao_sc5zc2',310),(32,'Bí ngòi nướng dầu oliu','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BiNgoiNuongDauOLiu_r8vjbp',85),(33,'Quả bưởi','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaBuoi_yqk3su',42),(34,'Cá nướng giấy bạc','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CaNuongGiayBac_k93qs4',140),(35,'Sốt táo không đường','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SotTaoKhongDuong_yhcba2',60),(36,'Canh khoai mỡ','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CanhKhoaiMo_ssvbzk',120),(37,'Thịt heo cuộn rau và bánh tráng','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ThitHeoCuonRauVaBanhTrang_qgvblg',245),(38,'Quả nho','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaNho_va4g5b',67),(39,'Cơm tinh bột','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/ComTinhBot_iy147v',130),(40,'Gà sốt bơ tỏi','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/GaSotBoToi_tznqmh',295),(41,'Súp lơ luộc','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SupLoLuoc_ycz3yf',34),(42,'Quả cam','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaCam_hufnzk',47),(43,'Canh sườn heo nạc nấu rau củ','Tối','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/CanhSuonHeoNacNauRauCu_lmscm5',180),(44,'Bánh mì quét bơ đậu phộng','Ăn nhẹ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BanhMiQuetBoDauPhong_p46yn8',190),(45,'Hạt tổng hợp','Ăn nhẹ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/HatTongHop_kyhdih',165),(46,'Quả dưa miếng','Ăn nhẹ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaDuaMieng_udc0i1',46),(47,'Sữa chua ít béo','Ăn nhẹ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SuaChuaItBeo_ae0fsw',80),(48,'Quả chuối','Ăn nhẹ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaChuoi_wbnmrb',89),(49,'Bánh mì nguyên cám','Ăn nhẹ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BanhMiNguyenCam_zprcuz',65),(50,'Quả dâu tây','Ăn nhẹ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaDauTay_uipf2z',32),(51,'Quả đào','Ăn nhẹ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/QuaDao_ivdeeo',39),(52,'Sữa chua ít béo và dâu tây','Ăn nhẹ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/SuaChuaItBeoVaDauTay_moetmw',110),(53,'Bơ tươi rắc hạt','Ăn nhẹ','https://res.cloudinary.com/dvuj2qfo3/image/upload/f_auto,q_auto/BoTuoiRacHat_lp8wtg',185);
/*!40000 ALTER TABLE `food_dictionary` ENABLE KEYS */;
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
  `unit` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `systolic_bp` int NOT NULL,
  `diastolic_bp` int NOT NULL,
  `heart_rate` int NOT NULL,
  `logged_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_blood_sugar_user` (`user_id`),
  CONSTRAINT `fk_blood_sugar_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `health_metrics_logs`
--

LOCK TABLES `health_metrics_logs` WRITE;
/*!40000 ALTER TABLE `health_metrics_logs` DISABLE KEYS */;
INSERT INTO `health_metrics_logs` VALUES (1,1,190,'mg/dL',160,80,110,'2026-06-03 07:30:30'),(2,1,65,'mg/dL',120,50,50,'2026-06-03 07:37:03'),(3,7,125,'mg/dL',110,80,70,'2026-06-03 08:07:36'),(4,8,190,'mg/dL',160,50,70,'2026-06-03 08:11:08'),(5,9,210,'mg/dL',50,50,70,'2026-06-03 09:13:15'),(7,11,210,'mg/dL',160,90,70,'2026-06-04 02:35:40');
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
  `medication_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `medication_category` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `medication_name` (`medication_name`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medication_dictionary`
--

LOCK TABLES `medication_dictionary` WRITE;
/*!40000 ALTER TABLE `medication_dictionary` DISABLE KEYS */;
INSERT INTO `medication_dictionary` VALUES (1,'Micronase (Glyburide)','Thuốc viên hạ đường huyết - Nhóm Sulfonylurea'),(2,'Glucotrol (Glipizide)','Thuốc viên hạ đường huyết - Nhóm Sulfonylurea'),(3,'Glucotrol XL (Glipizide ER)','Thuốc viên hạ đường huyết - Nhóm Sulfonylurea'),(4,'Amaryl (Glimepiride)','Thuốc viên hạ đường huyết - Nhóm Sulfonylurea'),(5,'Prandin (Repaglinide)','Thuốc viên hạ đường huyết - Nhóm Meglitinide'),(6,'Starlix (Nateglinide)','Thuốc viên hạ đường huyết - Nhóm Meglitinide'),(7,'Glucophage (Metformin)','Thuốc viên hạ đường huyết - Nhóm Biguanide (Metformin)'),(8,'Glucophage XR (Metformin ER)','Thuốc viên hạ đường huyết - Nhóm Biguanide (Metformin)'),(9,'Glumetza (Metformin ER)','Thuốc viên hạ đường huyết - Nhóm Biguanide (Metformin)'),(10,'Riomet (Metformin)','Thuốc viên hạ đường huyết - Nhóm Biguanide (Metformin)'),(11,'Fortamet (Metformin ER)','Thuốc viên hạ đường huyết - Nhóm Biguanide (Metformin)'),(12,'Januvia (Sitagliptin)','Thuốc viên hạ đường huyết - Nhóm ức chế DPP-4'),(13,'Onglyza (Saxagliptin)','Thuốc viên hạ đường huyết - Nhóm ức chế DPP-4'),(14,'Tradjenta (Linagliptin)','Thuốc viên hạ đường huyết - Nhóm ức chế DPP-4'),(15,'Nesina (Alogliptin)','Thuốc viên hạ đường huyết - Nhóm ức chế DPP-4'),(16,'Invokana (Canagliflozin)','Thuốc viên hạ đường huyết - Nhóm ức chế SGLT2'),(17,'Jardiance (Empagliflozin)','Thuốc viên hạ đường huyết - Nhóm ức chế SGLT2'),(18,'Farxiga (Dapagliflozin)','Thuốc viên hạ đường huyết - Nhóm ức chế SGLT2'),(19,'Steglatro (Ertugliflozin)','Thuốc viên hạ đường huyết - Nhóm ức chế SGLT2'),(20,'Rybelsus (Semaglutide)','Thuốc viên hạ đường huyết - Nhóm chủ vận GLP-1'),(21,'Insulin Actrapid (Insulin tác dụng nhanh)','Thuốc tiêm Insulin định kỳ'),(22,'Insulin Lantus SoloStar (Insulin nền kéo dài)','Thuốc tiêm Insulin định kỳ'),(23,'Vaxigrip Tetra - Pháp (Vaccine Cúm hàng năm)','Vaccine cúm dự phòng'),(24,'Prevenar 13 - Mỹ  (Vaccine Phế cầu khuẩn)','Vaccine phế cầu dự phòng'),(25,'NovoRapid / NovoLog (Insulin Aspart)','Thuốc tiêm Insulin bữa ăn (Siêu nhanh)'),(26,'Humalog (Insulin Lispro)','Thuốc tiêm Insulin bữa ăn (Siêu nhanh)'),(27,'Apidra (Insulin Glulisine)','Thuốc tiêm Insulin bữa ăn (Siêu nhanh)'),(28,'Fiasp (Insulin Aspart thế hệ mới)','Thuốc tiêm Insulin bữa ăn (Cực nhanh - Tiêm trong/sau ăn)'),(29,'Ademolog (Insulin Lispro-aabc)','Thuốc tiêm Insulin bữa ăn (Siêu nhanh)'),(30,'Tresiba (Insulin Degludec)','Thuốc tiêm Insulin định kỳ'),(31,'Levemir (Insulin Detemir)','Thuốc tiêm Insulin định kỳ'),(32,'Humulin (Insulin Người)','Thuốc tiêm Insulin định kỳ'),(33,'Novolin (Insulin Người)','Thuốc tiêm Insulin định kỳ'),(34,'Toujeo','Thuốc tiêm Insulin định kỳ (Nền kéo dài)'),(35,'Insulin NPH','Thuốc tiêm Insulin định kỳ (Tác dụng trung bình)'),(36,'Basaglar','Thuốc tiêm Insulin định kỳ (Nền kéo dài)'),(37,'Mixtard','Thuốc tiêm Insulin bữa ăn / Định kỳ (Hỗn hợp trộn sẵn)'),(38,'Novomix','Thuốc tiêm Insulin bữa ăn / Định kỳ (Hỗn hợp trộn sẵn)'),(39,'Insulatard','Thuốc tiêm Insulin định kỳ (Tác dụng trung bình)');
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
  `dosage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'taken',
  `notes` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logged_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_medication_user` (`user_id`),
  KEY `fk_medication_def` (`medication_def_id`),
  KEY `fk_medication_logs_reminders` (`reminder_id`),
  CONSTRAINT `fk_medication_def` FOREIGN KEY (`medication_def_id`) REFERENCES `medication_dictionary` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_medication_logs_reminders` FOREIGN KEY (`reminder_id`) REFERENCES `reminders` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_medication_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `otp_code` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_used` tinyint DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_otp_users` (`user_id`),
  CONSTRAINT `fk_otp_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otp_codes`
--

LOCK TABLES `otp_codes` WRITE;
/*!40000 ALTER TABLE `otp_codes` DISABLE KEYS */;
INSERT INTO `otp_codes` VALUES (1,1,'456945',1,'2026-06-03 07:22:41','2026-06-03 07:27:41'),(2,8,'964811',0,'2026-06-03 08:20:55','2026-06-03 08:25:54'),(3,8,'961574',0,'2026-06-03 08:21:13','2026-06-03 08:26:13'),(4,8,'666946',0,'2026-06-03 08:25:21','2026-06-03 08:30:21'),(5,8,'900435',0,'2026-06-03 08:30:39','2026-06-03 08:35:39'),(6,8,'673779',0,'2026-06-03 08:32:19','2026-06-03 08:37:19'),(7,8,'712411',0,'2026-06-03 08:34:04','2026-06-03 08:39:04'),(8,8,'673487',0,'2026-06-03 08:34:51','2026-06-03 08:39:51'),(9,8,'865903',1,'2026-06-03 08:41:14','2026-06-03 08:46:14'),(10,7,'797494',1,'2026-06-03 08:43:31','2026-06-03 08:48:31'),(11,7,'694737',1,'2026-06-03 09:02:12','2026-06-03 09:07:12'),(12,7,'846657',1,'2026-06-03 09:35:51','2026-06-03 09:40:51'),(13,7,'985365',1,'2026-06-03 09:36:51','2026-06-03 09:41:51'),(14,7,'808543',1,'2026-06-03 09:37:37','2026-06-03 09:42:37'),(15,7,'126778',1,'2026-06-03 09:39:37','2026-06-03 09:44:37');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_conditions`
--

LOCK TABLES `patient_conditions` WRITE;
/*!40000 ALTER TABLE `patient_conditions` DISABLE KEYS */;
INSERT INTO `patient_conditions` VALUES (4,6),(6,6),(2,7),(4,7),(6,7),(2,8),(3,8),(1,9),(1,13),(3,13),(6,13),(1,17),(2,17),(6,17);
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
  `Age` int NOT NULL,
  `target_low` int NOT NULL,
  `target_high` int NOT NULL,
  `weight` int NOT NULL,
  `height` int NOT NULL,
  `allergies` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `fk_profiles_user` (`user_id`),
  CONSTRAINT `fk_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_profiles`
--

LOCK TABLES `patient_profiles` WRITE;
/*!40000 ALTER TABLE `patient_profiles` DISABLE KEYS */;
INSERT INTO `patient_profiles` VALUES (1,1,26,70,180,80,178,NULL),(2,7,26,70,180,80,178,'dị ứng với thời tiết'),(3,8,26,70,180,70,178,NULL),(4,9,26,70,180,80,178,NULL),(6,11,26,70,180,60,167,NULL);
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
  `recorded_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`patient_profile_id`,`symptom_id`),
  KEY `fk_patient_symptom_def` (`symptom_id`),
  CONSTRAINT `fk_patient_symptom_def` FOREIGN KEY (`symptom_id`) REFERENCES `symptoms_dictionary` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_patient_symptom_profile` FOREIGN KEY (`patient_profile_id`) REFERENCES `patient_profiles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_symptoms`
--

LOCK TABLES `patient_symptoms` WRITE;
/*!40000 ALTER TABLE `patient_symptoms` DISABLE KEYS */;
INSERT INTO `patient_symptoms` VALUES (3,13,'2026-06-03 08:10:51'),(3,18,'2026-06-03 08:10:51'),(4,13,'2026-06-03 09:12:52'),(4,15,'2026-06-03 09:12:52'),(6,1,'2026-06-04 02:35:18'),(6,3,'2026-06-04 02:35:18');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `medication_dictionary_id` int NOT NULL,
  `title` varchar(300) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dosage` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reminder_time` time NOT NULL,
  `is_active` tinyint DEFAULT '1',
  `is_deleted` tinyint DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_reminders_user` (`user_id`),
  KEY `fk_reminders_medication` (`medication_dictionary_id`),
  CONSTRAINT `fk_reminders_medication` FOREIGN KEY (`medication_dictionary_id`) REFERENCES `medication_dictionary` (`id`),
  CONSTRAINT `fk_reminders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `symptom_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `symptoms_dictionary`
--

LOCK TABLES `symptoms_dictionary` WRITE;
/*!40000 ALTER TABLE `symptoms_dictionary` DISABLE KEYS */;
INSERT INTO `symptoms_dictionary` VALUES (1,'Vã mồ hôi lạnh','Hạ đường huyết'),(2,'Đói cồn cào, run tay chân','Hạ đường huyết'),(3,'Tim đập nhanh, hồi hộp','Hạ đường huyết'),(4,'Chóng mặt, đau đầu nhẹ','Hạ đường huyết'),(5,'Nhìn mờ, hoa mắt','Hạ đường huyết'),(6,'Mệt mỏi bứt rứt, cáu gắt','Hạ đường huyết'),(7,'Lú lẫn, nói lắp bắp','Hạ đường huyết'),(8,'Co giật hoặc ngất xỉu','Hạ đường huyết'),(9,'Khát nước liên tục (Khát nhiều)','Tăng đường huyết'),(10,'Đi tiểu nhiều lần (Đặc biệt ban đêm)','Tăng đường huyết'),(11,'Sụt cân nhanh không rõ lý do','Tăng đường huyết'),(12,'Mệt mỏi kéo dài, uể oải','Tăng đường huyết'),(13,'Tê bì, châm chích đầu ngón tay/chân','Tăng đường huyết'),(14,'Vết thương, vết loét lâu lành','Tăng đường huyết'),(15,'Hơi thở có mùi trái cây (Mùi táo chín)','Tăng đường huyết'),(16,'Thở nhanh, buồn nôn, lơ mơ','Tăng đường huyết'),(18,'Khô da','Tăng đường huyết'),(19,'Bệnh về nướu','Tăng đường huyết');
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
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `DOB` datetime NOT NULL,
  `hashed_password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'tin1234@gmail.com','2002-06-17 00:00:00','$2b$12$qdTi3P0Mpu8HwKxtDw4lQeJ.6LksOPs35EE8AhrZ45JG1flZgA0gK','Huỳnh Trọng Tín','2026-06-03 07:21:48'),(2,'nva1234@gmail.com','2000-01-01 00:00:00','$2b$12$e8U5dVly13CtzKWUKzXkkOn30pIqE1NcKEzKf5VgkpmBYYttNFXKK','Nguyễn Văn A','2026-06-03 07:36:03'),(3,'tva1234@gmail.com','2000-01-01 00:00:00','$2b$12$IYjIHgsLKVfPSNXy4ohbi.OCVBA/9.temC.ZxM.BFeVz3cOkuPQRS','Trần Văn A','2026-06-03 07:40:14'),(4,'tvb1234@gmail.com','2000-01-01 00:00:00','$2b$12$SDsiVYutqI01eBuZMta1AeuiPitUZ9Kmfdx3S7SvPDzhz8y7Hmicu','Trần Văn B','2026-06-03 07:55:38'),(5,'tvc1234@gmail.com','2000-01-01 00:00:00','$2b$12$NdvaJ5qmPbH.fU9VGHd4XOsF/DV68NoHB8UuMWyXVQrQdmiaAGUOy','Trần Văn C','2026-06-03 07:56:06'),(6,'nvb1234@gmail.com','2000-01-01 00:00:00','$2b$12$SzxRVx6SFhzr1DgKCvvCB.E7W4JH.M1gZMgOZvw6tZH2s4QV5HHS2','Nguyễn Văn B','2026-06-03 08:00:29'),(7,'httin1234@gmail.com','2000-01-01 00:00:00','$2b$12$5faoIfNrM.FVRmx6mf7ffuqR5JjuahRQ.pKLrmrhOp4OEwPfi3YsK','Huỳnh Trọng Tín','2026-06-03 08:06:16'),(8,'nvc1234@gmail.com','2000-01-01 00:00:00','$2b$12$d10QnmjnYGyhSusVetXTI./eqpwtF1KRtpLsacE.aMVWilDSNy9qa','Nguyễn Văn C','2026-06-03 08:10:30'),(9,'tvd1234@gmail.com','2000-01-01 00:00:00','$2b$12$5cOLpsxil9H8me9UZ.e61eW9YtBzIIl.9AuRZrUxlgTt8OOharuxW','Trần Văn D','2026-06-03 09:12:29'),(11,'ttb1234@gmail.com','2000-01-01 00:00:00','$2b$12$unT4ccY7z073IPsX1pOGz.bICAk8yipM3m6fXtpy01LLmhLb3Rw3K','Trần Thị B','2026-06-04 02:34:51');
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

-- Dump completed on 2026-06-04 10:13:12
