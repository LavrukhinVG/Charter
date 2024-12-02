
&ChangeAndValidate("pmInitializeReportBuilder")
Procedure Расш1_pmInitializeReportBuilder()
	ReportBuilder = New ReportBuilder();
	
	#Вставка
		QueryText = 
	"SELECT Разрешенные
	|	RoomInventoryMovements.Recorder AS Recorder,
	|	MAX(RoomInventoryMovements.Period) AS PeriodFrom
	|INTO EffectivePeriodsByRecorders
	|FROM
	|	AccumulationRegister.RoomInventory AS RoomInventoryMovements
	|WHERE
	|	RoomInventoryMovements.RecordType = VALUE(AccumulationRecordType.Expense)
	|	AND RoomInventoryMovements.Period <= &qPeriodTo
	|	AND RoomInventoryMovements.PeriodFrom <= &qPeriodTo
	|	AND RoomInventoryMovements.PeriodTo > &qPeriodTo
	|	AND (RoomInventoryMovements.IsReservation
	|			OR RoomInventoryMovements.IsAccommodation)
	|	AND (RoomInventoryMovements.Hotel IN HIERARCHY (&qHotel)
	|			OR &qIsEmptyHotel)
	|	AND (RoomInventoryMovements.Room IN HIERARCHY (&qRoom)
	|			OR &qIsEmptyRoom)
	|	AND (RoomInventoryMovements.RoomQuota IN HIERARCHY (&qRoomQuota)
	|			OR &qIsEmptyRoomQuota)
	|	AND (RoomInventoryMovements.RoomType IN HIERARCHY (&qRoomType)
	|			OR &qIsEmptyRoomType)
	|
	|GROUP BY
	|	RoomInventoryMovements.Recorder
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT Разрешенные
	|	RoomInventory.Hotel AS Hotel,
	|	RoomInventory.Status AS Status,
	|	RoomInventory.Room AS Room,
	|	RoomInventory.Customer AS Customer,
	|	RoomInventory.Contract AS Contract,
	|	RoomInventory.GuestGroup AS GuestGroup,
	|	RoomInventory.Guest AS Guest,
	|	RoomInventory.CheckInDate AS CheckInDate,
	|	RoomInventory.Duration AS Duration,
	|	RoomInventory.CheckOutDate AS CheckOutDate,
	|	RoomInventory.RoomType AS RoomType,
	|	RoomInventory.AccommodationType AS AccommodationType,
	|	RoomInventory.RoomQuota AS RoomQuota,
	|	RoomInventory.Remarks AS Remarks,
	|	RoomInventory.Recorder AS Recorder,
	|	RoomInventory.IsRoomInventory AS IsRoomInventory,
	|	RoomInventory.IsBlocking AS IsBlocking,
	|	RoomInventory.IsRoomQuota AS IsRoomQuota,
	|	RoomInventory.IsReservation AS IsReservation,
	|	RoomInventory.IsAccommodation AS IsAccommodation,
	|	RoomInventory.RoomsVacant AS RoomsVacant,
	|	RoomInventory.BedsVacant AS BedsVacant
	|{SELECT
	|	Hotel.*,
	|	Recorder.*,
	|	Status.*,
	|	Room.*,
	|	Customer.*,
	|	Contract.*,
	|	GuestGroup.*,
	|	Guest.*,
	|	CheckInDate,
	|	Duration,
	|	CheckOutDate,
	|	RoomType.*,
	|	AccommodationType.*,
	|	RoomQuota.*,
	|	Remarks,
	|	IsRoomInventory,
	|	IsBlocking,
	|	IsRoomQuota,
	|	IsReservation,
	|	IsAccommodation,
	|	RoomsVacant,
	|	BedsVacant}
	|FROM
	|	(SELECT DISTINCT
	|		RoomInventoryMovements.Hotel AS Hotel,
	|		RoomInventoryMovements.Status AS Status,
	|		RoomInventoryMovements.Room AS Room,
	|		RoomInventoryMovements.Customer AS Customer,
	|		RoomInventoryMovements.Contract AS Contract,
	|		RoomInventoryMovements.GuestGroup AS GuestGroup,
	|		RoomInventoryMovements.Guest AS Guest,
	|		RoomInventoryMovements.CheckInDate AS CheckInDate,
	|		RoomInventoryMovements.Duration AS Duration,
	|		RoomInventoryMovements.CheckOutDate AS CheckOutDate,
	|		RoomInventoryMovements.RoomType AS RoomType,
	|		RoomInventoryMovements.AccommodationType AS AccommodationType,
	|		RoomInventoryMovements.RoomQuota AS RoomQuota,
	|		CAST(RoomInventoryMovements.Remarks AS STRING(1024)) AS Remarks,
	|		RoomInventoryMovements.Recorder AS Recorder,
	|		RoomInventoryMovements.IsRoomInventory AS IsRoomInventory,
	|		RoomInventoryMovements.IsBlocking AS IsBlocking,
	|		RoomInventoryMovements.IsRoomQuota AS IsRoomQuota,
	|		RoomInventoryMovements.IsReservation AS IsReservation,
	|		RoomInventoryMovements.IsAccommodation AS IsAccommodation,
	|		RoomInventoryMovements.RoomsVacant AS RoomsVacant,
	|		RoomInventoryMovements.BedsVacant AS BedsVacant
	|	FROM
	|		(SELECT
	|			AvailableRooms.Hotel AS Hotel,
	|			NULL AS Status,
	|			NULL AS Room,
	|			NULL AS Customer,
	|			NULL AS Contract,
	|			NULL AS GuestGroup,
	|			NULL AS Guest,
	|			NULL AS CheckInDate,
	|			NULL AS Duration,
	|			NULL AS CheckOutDate,
	|			NULL AS RoomType,
	|			NULL AS AccommodationType,
	|			NULL AS RoomQuota,
	|			NULL AS Remarks,
	|			NULL AS Recorder,
	|			TRUE AS IsRoomInventory,
	|			FALSE AS IsBlocking,
	|			FALSE AS IsRoomQuota,
	|			FALSE AS IsReservation,
	|			FALSE AS IsAccommodation,
	|			ISNULL(AvailableRooms.TotalRoomsBalance, 0) AS RoomsVacant,
	|			ISNULL(AvailableRooms.TotalBedsBalance, 0) AS BedsVacant
	|		FROM
	|			AccumulationRegister.RoomInventory.Balance(
	|					&qPeriodTo,
	|					&qIsEmptyRoomQuota
	|						AND (Hotel IN HIERARCHY (&qHotel)
	|							OR &qIsEmptyHotel)
	|						AND (Room IN HIERARCHY (&qRoom)
	|							OR &qIsEmptyRoom)
	|						AND (RoomType IN HIERARCHY (&qRoomType)
	|							OR &qIsEmptyRoomType)) AS AvailableRooms
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			RoomBlocks.Hotel,
	|			RoomBlocks.RoomBlockType,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			FALSE,
	|			TRUE,
	|			FALSE,
	|			FALSE,
	|			FALSE,
	|			-ISNULL(RoomBlocks.RoomsBlockedBalance, 0),
	|			-ISNULL(RoomBlocks.BedsBlockedBalance, 0)
	|		FROM
	|			AccumulationRegister.RoomBlocks.Balance(
	|					&qPeriodTo,
	|					&qIsEmptyRoomQuota
	|						AND (Hotel IN HIERARCHY (&qHotel)
	|							OR &qIsEmptyHotel)
	|						AND (Room IN HIERARCHY (&qRoom)
	|							OR &qIsEmptyRoom)
	|						AND (RoomType IN HIERARCHY (&qRoomType)
	|							OR &qIsEmptyRoomType)) AS RoomBlocks
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			RoomQuotas.Hotel,
	|			RoomQuotas.RoomQuota,
	|			NULL,
	|			RoomQuotas.RoomQuota.Customer,
	|			RoomQuotas.RoomQuota.Contract,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			RoomQuotas.RoomQuota,
	|			NULL,
	|			NULL,
	|			FALSE,
	|			FALSE,
	|			TRUE,
	|			FALSE,
	|			FALSE,
	|			-ISNULL(RoomQuotas.RoomsRemainsBalance, 0),
	|			-ISNULL(RoomQuotas.BedsRemainsBalance, 0)
	|		FROM
	|			AccumulationRegister.RoomQuotaSales.Balance(
	|					&qPeriodTo,
	|					RoomQuota.DoWriteOff
	|						AND (Hotel IN HIERARCHY (&qHotel)
	|							OR &qIsEmptyHotel)
	|						AND (RoomQuota IN HIERARCHY (&qRoomQuota)
	|							OR &qIsEmptyRoomQuota)
	|						AND (Room IN HIERARCHY (&qRoom)
	|							OR &qIsEmptyRoom)
	|						AND (RoomType IN HIERARCHY (&qRoomType)
	|							OR &qIsEmptyRoomType)) AS RoomQuotas
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			Reservations.Hotel,
	|			Reservations.ReservationStatus,
	|			Reservations.Room,
	|			Reservations.Customer,
	|			Reservations.Contract,
	|			Reservations.GuestGroup,
	|			Reservations.Guest,
	|			Reservations.PeriodFrom,
	|			Reservations.PeriodDuration,
	|			Reservations.PeriodTo,
	|			Reservations.RoomType,
	|			Reservations.AccommodationType,
	|			Reservations.RoomQuota,
	|			Reservations.Remarks,
	|			Reservations.Recorder,
	|			FALSE,
	|			FALSE,
	|			FALSE,
	|			TRUE,
	|			FALSE,
	|			-Reservations.RoomsVacant,
	|			-Reservations.BedsVacant
	|		FROM
	|			AccumulationRegister.RoomInventory AS Reservations
	|				INNER JOIN EffectivePeriodsByRecorders AS EffectivePeriodsByRecorders
	|				ON Reservations.Recorder = EffectivePeriodsByRecorders.Recorder
	|					AND Reservations.Period = EffectivePeriodsByRecorders.PeriodFrom
	|		WHERE
	|			Reservations.RecordType = VALUE(AccumulationRecordType.Expense)
	|			AND Reservations.IsReservation
	|			AND (Reservations.Hotel IN HIERARCHY (&qHotel)
	|					OR &qIsEmptyHotel)
	|			AND (Reservations.Room IN HIERARCHY (&qRoom)
	|					OR &qIsEmptyRoom)
	|			AND (Reservations.RoomQuota IN HIERARCHY (&qRoomQuota)
	|					OR &qIsEmptyRoomQuota)
	|			AND (Reservations.RoomType IN HIERARCHY (&qRoomType)
	|					OR &qIsEmptyRoomType)
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			Accommodations.Hotel,
	|			Accommodations.AccommodationStatus,
	|			Accommodations.Room,
	|			Accommodations.Customer,
	|			Accommodations.Contract,
	|			Accommodations.GuestGroup,
	|			Accommodations.Guest,
	|			Accommodations.PeriodFrom,
	|			Accommodations.PeriodDuration,
	|			Accommodations.PeriodTo,
	|			Accommodations.RoomType,
	|			Accommodations.AccommodationType,
	|			Accommodations.RoomQuota,
	|			Accommodations.Remarks,
	|			Accommodations.Recorder,
	|			FALSE,
	|			FALSE,
	|			FALSE,
	|			FALSE,
	|			TRUE,
	|			-Accommodations.RoomsVacant,
	|			-Accommodations.BedsVacant
	|		FROM
	|			AccumulationRegister.RoomInventory AS Accommodations
	|				INNER JOIN EffectivePeriodsByRecorders AS EffectivePeriodsByRecorders
	|				ON Accommodations.Recorder = EffectivePeriodsByRecorders.Recorder
	|					AND Accommodations.Period = EffectivePeriodsByRecorders.PeriodFrom
	|		WHERE
	|			Accommodations.RecordType = VALUE(AccumulationRecordType.Expense)
	|			AND Accommodations.IsAccommodation
	|			AND (Accommodations.Hotel IN HIERARCHY (&qHotel)
	|					OR &qIsEmptyHotel)
	|			AND (Accommodations.Room IN HIERARCHY (&qRoom)
	|					OR &qIsEmptyRoom)
	|			AND (Accommodations.RoomQuota IN HIERARCHY (&qRoomQuota)
	|					OR &qIsEmptyRoomQuota)
	|			AND (Accommodations.RoomType IN HIERARCHY (&qRoomType)
	|					OR &qIsEmptyRoomType)) AS RoomInventoryMovements) AS RoomInventory
	|{WHERE
	|	RoomInventory.Hotel.*,
	|	RoomInventory.Status.*,
	|	RoomInventory.Room.*,
	|	RoomInventory.Customer.*,
	|	RoomInventory.Contract.*,
	|	RoomInventory.GuestGroup.*,
	|	RoomInventory.Guest.*,
	|	RoomInventory.CheckInDate,
	|	RoomInventory.Duration,
	|	RoomInventory.CheckOutDate,
	|	RoomInventory.RoomType.*,
	|	RoomInventory.AccommodationType.*,
	|	RoomInventory.RoomQuota.*,
	|	RoomInventory.Remarks,
	|	RoomInventory.Recorder.*,
	|	RoomInventory.IsRoomInventory,
	|	RoomInventory.IsBlocking,
	|	RoomInventory.IsRoomQuota,
	|	RoomInventory.IsReservation,
	|	RoomInventory.IsAccommodation,
	|	RoomInventory.RoomsVacant,
	|	RoomInventory.BedsVacant}
	|
	|ORDER BY
	|	Hotel,
	|	IsRoomInventory DESC,
	|	IsBlocking DESC,
	|	IsRoomQuota DESC,
	|	IsReservation DESC,
	|	IsAccommodation DESC,
	|	Customer,
	|	Room,
	|	CheckInDate,
	|	Guest
	|{ORDER BY
	|	Hotel.*,
	|	Status.*,
	|	Room.*,
	|	Customer.*,
	|	Contract.*,
	|	GuestGroup.*,
	|	Guest.*,
	|	CheckInDate,
	|	Duration,
	|	CheckOutDate,
	|	RoomType.*,
	|	AccommodationType.*,
	|	RoomQuota.*,
	|	Remarks,
	|	Recorder.*,
	|	IsRoomInventory,
	|	IsBlocking,
	|	IsRoomQuota,
	|	IsReservation,
	|	IsAccommodation,
	|	RoomsVacant,
	|	BedsVacant}
	|TOTALS
	|	SUM(RoomsVacant),
	|	SUM(BedsVacant)
	|BY
	|	OVERALL,
	|	Customer
	|{TOTALS BY
	|	Hotel.*,
	|	Status.*,
	|	Room.*,
	|	Customer.*,
	|	Contract.*,
	|	GuestGroup.*,
	|	Guest.*,
	|	RoomType.*,
	|	RoomQuota.*,
	|	Recorder.*,
	|	IsRoomInventory,
	|	IsBlocking,
	|	IsRoomQuota,
	|	IsReservation,
	|	IsAccommodation}";
	#КонецВставки
	
	// Initialize default query text
	#Удаление
	QueryText = 
	"SELECT
	|	RoomInventoryMovements.Recorder AS Recorder,
	|	MAX(RoomInventoryMovements.Period) AS PeriodFrom
	|INTO EffectivePeriodsByRecorders
	|FROM
	|	AccumulationRegister.RoomInventory AS RoomInventoryMovements
	|WHERE
	|	RoomInventoryMovements.RecordType = VALUE(AccumulationRecordType.Expense)
	|	AND RoomInventoryMovements.Period <= &qPeriodTo
	|	AND RoomInventoryMovements.PeriodFrom <= &qPeriodTo
	|	AND RoomInventoryMovements.PeriodTo > &qPeriodTo
	|	AND (RoomInventoryMovements.IsReservation
	|			OR RoomInventoryMovements.IsAccommodation)
	|	AND (RoomInventoryMovements.Hotel IN HIERARCHY (&qHotel)
	|			OR &qIsEmptyHotel)
	|	AND (RoomInventoryMovements.Room IN HIERARCHY (&qRoom)
	|			OR &qIsEmptyRoom)
	|	AND (RoomInventoryMovements.RoomQuota IN HIERARCHY (&qRoomQuota)
	|			OR &qIsEmptyRoomQuota)
	|	AND (RoomInventoryMovements.RoomType IN HIERARCHY (&qRoomType)
	|			OR &qIsEmptyRoomType)
	|
	|GROUP BY
	|	RoomInventoryMovements.Recorder
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	RoomInventory.Hotel AS Hotel,
	|	RoomInventory.Status AS Status,
	|	RoomInventory.Room AS Room,
	|	RoomInventory.Customer AS Customer,
	|	RoomInventory.Contract AS Contract,
	|	RoomInventory.GuestGroup AS GuestGroup,
	|	RoomInventory.Guest AS Guest,
	|	RoomInventory.CheckInDate AS CheckInDate,
	|	RoomInventory.Duration AS Duration,
	|	RoomInventory.CheckOutDate AS CheckOutDate,
	|	RoomInventory.RoomType AS RoomType,
	|	RoomInventory.AccommodationType AS AccommodationType,
	|	RoomInventory.RoomQuota AS RoomQuota,
	|	RoomInventory.Remarks AS Remarks,
	|	RoomInventory.Recorder AS Recorder,
	|	RoomInventory.IsRoomInventory AS IsRoomInventory,
	|	RoomInventory.IsBlocking AS IsBlocking,
	|	RoomInventory.IsRoomQuota AS IsRoomQuota,
	|	RoomInventory.IsReservation AS IsReservation,
	|	RoomInventory.IsAccommodation AS IsAccommodation,
	|	RoomInventory.RoomsVacant AS RoomsVacant,
	|	RoomInventory.BedsVacant AS BedsVacant
	|{SELECT
	|	Hotel.*,
	|	Recorder.*,
	|	Status.*,
	|	Room.*,
	|	Customer.*,
	|	Contract.*,
	|	GuestGroup.*,
	|	Guest.*,
	|	CheckInDate,
	|	Duration,
	|	CheckOutDate,
	|	RoomType.*,
	|	AccommodationType.*,
	|	RoomQuota.*,
	|	Remarks,
	|	IsRoomInventory,
	|	IsBlocking,
	|	IsRoomQuota,
	|	IsReservation,
	|	IsAccommodation,
	|	RoomsVacant,
	|	BedsVacant}
	|FROM
	|	(SELECT DISTINCT
	|		RoomInventoryMovements.Hotel AS Hotel,
	|		RoomInventoryMovements.Status AS Status,
	|		RoomInventoryMovements.Room AS Room,
	|		RoomInventoryMovements.Customer AS Customer,
	|		RoomInventoryMovements.Contract AS Contract,
	|		RoomInventoryMovements.GuestGroup AS GuestGroup,
	|		RoomInventoryMovements.Guest AS Guest,
	|		RoomInventoryMovements.CheckInDate AS CheckInDate,
	|		RoomInventoryMovements.Duration AS Duration,
	|		RoomInventoryMovements.CheckOutDate AS CheckOutDate,
	|		RoomInventoryMovements.RoomType AS RoomType,
	|		RoomInventoryMovements.AccommodationType AS AccommodationType,
	|		RoomInventoryMovements.RoomQuota AS RoomQuota,
	|		CAST(RoomInventoryMovements.Remarks AS STRING(1024)) AS Remarks,
	|		RoomInventoryMovements.Recorder AS Recorder,
	|		RoomInventoryMovements.IsRoomInventory AS IsRoomInventory,
	|		RoomInventoryMovements.IsBlocking AS IsBlocking,
	|		RoomInventoryMovements.IsRoomQuota AS IsRoomQuota,
	|		RoomInventoryMovements.IsReservation AS IsReservation,
	|		RoomInventoryMovements.IsAccommodation AS IsAccommodation,
	|		RoomInventoryMovements.RoomsVacant AS RoomsVacant,
	|		RoomInventoryMovements.BedsVacant AS BedsVacant
	|	FROM
	|		(SELECT
	|			AvailableRooms.Hotel AS Hotel,
	|			NULL AS Status,
	|			NULL AS Room,
	|			NULL AS Customer,
	|			NULL AS Contract,
	|			NULL AS GuestGroup,
	|			NULL AS Guest,
	|			NULL AS CheckInDate,
	|			NULL AS Duration,
	|			NULL AS CheckOutDate,
	|			NULL AS RoomType,
	|			NULL AS AccommodationType,
	|			NULL AS RoomQuota,
	|			NULL AS Remarks,
	|			NULL AS Recorder,
	|			TRUE AS IsRoomInventory,
	|			FALSE AS IsBlocking,
	|			FALSE AS IsRoomQuota,
	|			FALSE AS IsReservation,
	|			FALSE AS IsAccommodation,
	|			ISNULL(AvailableRooms.TotalRoomsBalance, 0) AS RoomsVacant,
	|			ISNULL(AvailableRooms.TotalBedsBalance, 0) AS BedsVacant
	|		FROM
	|			AccumulationRegister.RoomInventory.Balance(
	|					&qPeriodTo,
	|					&qIsEmptyRoomQuota
	|						AND (Hotel IN HIERARCHY (&qHotel)
	|							OR &qIsEmptyHotel)
	|						AND (Room IN HIERARCHY (&qRoom)
	|							OR &qIsEmptyRoom)
	|						AND (RoomType IN HIERARCHY (&qRoomType)
	|							OR &qIsEmptyRoomType)) AS AvailableRooms
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			RoomBlocks.Hotel,
	|			RoomBlocks.RoomBlockType,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			FALSE,
	|			TRUE,
	|			FALSE,
	|			FALSE,
	|			FALSE,
	|			-ISNULL(RoomBlocks.RoomsBlockedBalance, 0),
	|			-ISNULL(RoomBlocks.BedsBlockedBalance, 0)
	|		FROM
	|			AccumulationRegister.RoomBlocks.Balance(
	|					&qPeriodTo,
	|					&qIsEmptyRoomQuota
	|						AND (Hotel IN HIERARCHY (&qHotel)
	|							OR &qIsEmptyHotel)
	|						AND (Room IN HIERARCHY (&qRoom)
	|							OR &qIsEmptyRoom)
	|						AND (RoomType IN HIERARCHY (&qRoomType)
	|							OR &qIsEmptyRoomType)) AS RoomBlocks
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			RoomQuotas.Hotel,
	|			RoomQuotas.RoomQuota,
	|			NULL,
	|			RoomQuotas.RoomQuota.Customer,
	|			RoomQuotas.RoomQuota.Contract,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			NULL,
	|			RoomQuotas.RoomQuota,
	|			NULL,
	|			NULL,
	|			FALSE,
	|			FALSE,
	|			TRUE,
	|			FALSE,
	|			FALSE,
	|			-ISNULL(RoomQuotas.RoomsRemainsBalance, 0),
	|			-ISNULL(RoomQuotas.BedsRemainsBalance, 0)
	|		FROM
	|			AccumulationRegister.RoomQuotaSales.Balance(
	|					&qPeriodTo,
	|					RoomQuota.DoWriteOff
	|						AND (Hotel IN HIERARCHY (&qHotel)
	|							OR &qIsEmptyHotel)
	|						AND (RoomQuota IN HIERARCHY (&qRoomQuota)
	|							OR &qIsEmptyRoomQuota)
	|						AND (Room IN HIERARCHY (&qRoom)
	|							OR &qIsEmptyRoom)
	|						AND (RoomType IN HIERARCHY (&qRoomType)
	|							OR &qIsEmptyRoomType)) AS RoomQuotas
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			Reservations.Hotel,
	|			Reservations.ReservationStatus,
	|			Reservations.Room,
	|			Reservations.Customer,
	|			Reservations.Contract,
	|			Reservations.GuestGroup,
	|			Reservations.Guest,
	|			Reservations.PeriodFrom,
	|			Reservations.PeriodDuration,
	|			Reservations.PeriodTo,
	|			Reservations.RoomType,
	|			Reservations.AccommodationType,
	|			Reservations.RoomQuota,
	|			Reservations.Remarks,
	|			Reservations.Recorder,
	|			FALSE,
	|			FALSE,
	|			FALSE,
	|			TRUE,
	|			FALSE,
	|			-Reservations.RoomsVacant,
	|			-Reservations.BedsVacant
	|		FROM
	|			AccumulationRegister.RoomInventory AS Reservations
	|				INNER JOIN EffectivePeriodsByRecorders AS EffectivePeriodsByRecorders
	|				ON Reservations.Recorder = EffectivePeriodsByRecorders.Recorder
	|					AND Reservations.Period = EffectivePeriodsByRecorders.PeriodFrom
	|		WHERE
	|			Reservations.RecordType = VALUE(AccumulationRecordType.Expense)
	|			AND Reservations.IsReservation
	|			AND (Reservations.Hotel IN HIERARCHY (&qHotel)
	|					OR &qIsEmptyHotel)
	|			AND (Reservations.Room IN HIERARCHY (&qRoom)
	|					OR &qIsEmptyRoom)
	|			AND (Reservations.RoomQuota IN HIERARCHY (&qRoomQuota)
	|					OR &qIsEmptyRoomQuota)
	|			AND (Reservations.RoomType IN HIERARCHY (&qRoomType)
	|					OR &qIsEmptyRoomType)
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			Accommodations.Hotel,
	|			Accommodations.AccommodationStatus,
	|			Accommodations.Room,
	|			Accommodations.Customer,
	|			Accommodations.Contract,
	|			Accommodations.GuestGroup,
	|			Accommodations.Guest,
	|			Accommodations.PeriodFrom,
	|			Accommodations.PeriodDuration,
	|			Accommodations.PeriodTo,
	|			Accommodations.RoomType,
	|			Accommodations.AccommodationType,
	|			Accommodations.RoomQuota,
	|			Accommodations.Remarks,
	|			Accommodations.Recorder,
	|			FALSE,
	|			FALSE,
	|			FALSE,
	|			FALSE,
	|			TRUE,
	|			-Accommodations.RoomsVacant,
	|			-Accommodations.BedsVacant
	|		FROM
	|			AccumulationRegister.RoomInventory AS Accommodations
	|				INNER JOIN EffectivePeriodsByRecorders AS EffectivePeriodsByRecorders
	|				ON Accommodations.Recorder = EffectivePeriodsByRecorders.Recorder
	|					AND Accommodations.Period = EffectivePeriodsByRecorders.PeriodFrom
	|		WHERE
	|			Accommodations.RecordType = VALUE(AccumulationRecordType.Expense)
	|			AND Accommodations.IsAccommodation
	|			AND (Accommodations.Hotel IN HIERARCHY (&qHotel)
	|					OR &qIsEmptyHotel)
	|			AND (Accommodations.Room IN HIERARCHY (&qRoom)
	|					OR &qIsEmptyRoom)
	|			AND (Accommodations.RoomQuota IN HIERARCHY (&qRoomQuota)
	|					OR &qIsEmptyRoomQuota)
	|			AND (Accommodations.RoomType IN HIERARCHY (&qRoomType)
	|					OR &qIsEmptyRoomType)) AS RoomInventoryMovements) AS RoomInventory
	|{WHERE
	|	RoomInventory.Hotel.*,
	|	RoomInventory.Status.*,
	|	RoomInventory.Room.*,
	|	RoomInventory.Customer.*,
	|	RoomInventory.Contract.*,
	|	RoomInventory.GuestGroup.*,
	|	RoomInventory.Guest.*,
	|	RoomInventory.CheckInDate,
	|	RoomInventory.Duration,
	|	RoomInventory.CheckOutDate,
	|	RoomInventory.RoomType.*,
	|	RoomInventory.AccommodationType.*,
	|	RoomInventory.RoomQuota.*,
	|	RoomInventory.Remarks,
	|	RoomInventory.Recorder.*,
	|	RoomInventory.IsRoomInventory,
	|	RoomInventory.IsBlocking,
	|	RoomInventory.IsRoomQuota,
	|	RoomInventory.IsReservation,
	|	RoomInventory.IsAccommodation,
	|	RoomInventory.RoomsVacant,
	|	RoomInventory.BedsVacant}
	|
	|ORDER BY
	|	Hotel,
	|	IsRoomInventory DESC,
	|	IsBlocking DESC,
	|	IsRoomQuota DESC,
	|	IsReservation DESC,
	|	IsAccommodation DESC,
	|	Customer,
	|	Room,
	|	CheckInDate,
	|	Guest
	|{ORDER BY
	|	Hotel.*,
	|	Status.*,
	|	Room.*,
	|	Customer.*,
	|	Contract.*,
	|	GuestGroup.*,
	|	Guest.*,
	|	CheckInDate,
	|	Duration,
	|	CheckOutDate,
	|	RoomType.*,
	|	AccommodationType.*,
	|	RoomQuota.*,
	|	Remarks,
	|	Recorder.*,
	|	IsRoomInventory,
	|	IsBlocking,
	|	IsRoomQuota,
	|	IsReservation,
	|	IsAccommodation,
	|	RoomsVacant,
	|	BedsVacant}
	|TOTALS
	|	SUM(RoomsVacant),
	|	SUM(BedsVacant)
	|BY
	|	OVERALL,
	|	Customer
	|{TOTALS BY
	|	Hotel.*,
	|	Status.*,
	|	Room.*,
	|	Customer.*,
	|	Contract.*,
	|	GuestGroup.*,
	|	Guest.*,
	|	RoomType.*,
	|	RoomQuota.*,
	|	Recorder.*,
	|	IsRoomInventory,
	|	IsBlocking,
	|	IsRoomQuota,
	|	IsReservation,
	|	IsAccommodation}";
	#КонецУдаления
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();
	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);

	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("EN='Room inventory';RU='Загрузка номеров';de='Laden von Zimmern'");

	// Fill report builder fields presentations from the report template
	cmFillReportAttributesPresentations(ThisObject);

	// Reset report builder template
	ReportBuilder.Template = Undefined;EndProcedure
