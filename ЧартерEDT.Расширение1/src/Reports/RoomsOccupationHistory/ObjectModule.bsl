
&ChangeAndValidate("pmInitializeReportBuilder")
Procedure Расш1_pmInitializeReportBuilder()
	ReportBuilder = New ReportBuilder();

	// Initialize default query text
	#Вставка
	QueryText = 
	"SELECT Разрешенные
	|	RoomInventory.Recorder.Hotel AS Hotel,
	|	RoomInventory.Room AS Room,
	|	RoomInventory.Recorder.Customer AS Customer,
	|	RoomInventory.Recorder.AccommodationStatus AS AccommodationStatus,
	|	RoomInventory.Recorder.Guest AS Guest,
	|	RoomInventory.CheckInDate AS CheckInDate,
	|	RoomInventory.Duration AS Duration,
	|	RoomInventory.CheckOutDate AS CheckOutDate,
	|	RoomInventory.RoomType AS RoomType,
	|	RoomInventory.AccommodationType AS AccommodationType,
	|	RoomInventory.Recorder.RoomRate AS RoomRate,
	|	RoomInventory.Recorder.Remarks AS Remarks,
	|	RoomInventory.Recorder.GuestGroup AS GuestGroup,
	|	CASE
	|		WHEN &qShowMainRoomGuestsOnly
	|			THEN ISNULL(RoomInventory.Recorder.NumberOfAdults, 0) + ISNULL(RoomInventory.Recorder.NumberOfTeenagers, 0) + ISNULL(RoomInventory.Recorder.NumberOfChildren, 0) + ISNULL(RoomInventory.Recorder.NumberOfInfants, 0)
	|		ELSE RoomInventory.InHouseGuests
	|	END AS InHouseGuests,
	|	ISNULL(RoomInventory.Recorder.NumberOfAdults, 0) AS NumberOfAdults,
	|	ISNULL(RoomInventory.Recorder.NumberOfTeenagers, 0) AS NumberOfTeenagers,
	|	ISNULL(RoomInventory.Recorder.NumberOfChildren, 0) AS NumberOfChildren,
	|	ISNULL(RoomInventory.Recorder.NumberOfInfants, 0) AS NumberOfInfants,
	|	RoomInventory.InHouseRooms AS InHouseRooms,
	|	RoomInventory.InHouseBeds AS InHouseBeds,
	|	RoomInventory.InHouseAdditionalBeds AS InHouseAdditionalBeds,
	|	RoomInventory.Recorder.HotelProduct.Sum AS HotelProductSum,
	|	RoomInventory.Recorder.PricePresentation AS PricePresentation,
	|	ExpectedRoomMoves.Room AS RoomTo,
	|	ISNULL(GuestPeriodSales.Sales, 0) AS Sales,
	|	ISNULL(GuestPeriodSales.RoomRevenue, 0) AS RoomRevenue,
	|	ISNULL(ClientBalances.ClientSumBalance, 0) AS ClientSumBalance,
	|	ISNULL(ClientTotals.NumberOfCheckins, 0) AS NumberOfCheckins
	|{SELECT
	|	Hotel.*,
	|	Room.*,
	|	RoomInventory.Recorder.CustomerType.* AS CustomerType,
	|	Customer.*,
	|	RoomInventory.Recorder.Contract.* AS Contract,
	|	RoomInventory.Recorder.ContactPerson AS ContactPerson,
	|	RoomInventory.Recorder.Agent.* AS Agent,
	|	RoomInventory.Recorder.ClientType.* AS ClientType,
	|	Guest.*,
	|	CheckInDate,
	|	Duration,
	|	CheckOutDate,
	|	RoomInventory.CheckInAccountingDate AS CheckInAccountingDate,
	|	RoomInventory.CheckOutAccountingDate AS CheckOutAccountingDate,
	|	(HOUR(RoomInventory.Recorder.CheckInDate)) AS CheckInHour,
	|	(DAY(RoomInventory.Recorder.CheckInDate)) AS CheckInDay,
	|	(WEEK(RoomInventory.Recorder.CheckInDate)) AS CheckInWeek,
	|	(MONTH(RoomInventory.Recorder.CheckInDate)) AS CheckInMonth,
	|	(QUARTER(RoomInventory.Recorder.CheckInDate)) AS CheckInQuarter,
	|	(YEAR(RoomInventory.Recorder.CheckInDate)) AS CheckInYear,
	|	RoomType.*,
	|	AccommodationType.*,
	|	RoomInventory.Recorder.RoomRateType.* AS RoomRateType,
	|	RoomInventory.Recorder.AccommodationTemplate.* AS AccommodationTemplate,
	|	RoomRate.*,
	|	PricePresentation,
	|	RoomInventory.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	InHouseGuests,
	|	NumberOfAdults,
	|	NumberOfTeenagers,
	|	NumberOfChildren,
	|	NumberOfInfants,
	|	InHouseRooms,
	|	InHouseBeds,
	|	InHouseAdditionalBeds,
	|	Remarks,
	|	RoomInventory.Recorder.Car AS Car,
	|	GuestGroup.*,
	|	AccommodationStatus.*,
	|	RoomInventory.Recorder.IsMaster AS IsMaster,
	|	RoomInventory.Recorder.HotelProduct.* AS HotelProduct,
	|	RoomInventory.Recorder.RoomQuota.* AS RoomQuota,
	|	RoomInventory.Recorder.MarketingCode.* AS MarketingCode,
	|	RoomInventory.Recorder.TripPurpose.* AS TripPurpose,
	|	RoomInventory.Recorder.SourceOfBusiness.* AS SourceOfBusiness,
	|	RoomInventory.Recorder.DiscountCard.* AS DiscountCard,
	|	RoomInventory.Recorder.DiscountType.* AS DiscountType,
	|	RoomInventory.Recorder.Discount AS Discount,
	|	RoomInventory.Recorder.AgentCommission AS AgentCommission,
	|	RoomInventory.Recorder.AgentCommissionType AS AgentCommissionType,
	|	RoomInventory.Recorder.RoomQuantity AS RoomQuantity,
	|	RoomInventory.Recorder.NumberOfBedsPerRoom AS NumberOfBedsPerRoom,
	|	RoomInventory.Recorder.NumberOfPersonsPerRoom AS NumberOfPersonsPerRoom,
	|	HotelProductSum,
	|	RoomInventory.Recorder.HotelProduct.Currency.* AS HotelProductCurrency,
	|	RoomInventory.Recorder.ParentDoc.* AS ParentDoc,
	|	RoomInventory.Recorder.Author.* AS Author,
	|	RoomInventory.Recorder.* AS Recorder,
	|	RoomTo.*,
	|	RoomInventory.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
	|	RoomInventory.ClientDataScan.* AS ClientDataScan,
	|	(CASE
	|			WHEN RoomInventory.ForeignerRegistryRecord.MigrationCardDateTo <> &qEmptyDate
	|				THEN DATEDIFF(RoomInventory.ForeignerRegistryRecord.MigrationCardDateTo, RoomInventory.Recorder.CheckOutDate, DAY)
	|			ELSE 0
	|		END) AS MigrationCardDateToDeviance,
	|	(CASE
	|			WHEN RoomInventory.ForeignerRegistryRecord.VisaToDate <> &qEmptyDate
	|				THEN DATEDIFF(RoomInventory.ForeignerRegistryRecord.VisaToDate, RoomInventory.Recorder.CheckOutDate, DAY)
	|			ELSE 0
	|		END) AS VisaToDateDeviance,
	|	RoomInventory.Recorder.PointInTime AS PointInTime,
	|	Sales,
	|	RoomRevenue,
	|	ClientSumBalance,
	|	NumberOfCheckins,
	|	(NULL) AS EmptyColumn}
	|FROM
	|	(SELECT
	|		RoomInventoryPeriods.Recorder AS Recorder,
	|		RoomInventoryPeriods.Room AS Room,
	|		RoomInventoryPeriods.RoomType AS RoomType,
	|		RoomInventoryPeriods.AccommodationType AS AccommodationType,
	|		RoomInventoryPeriods.PeriodFrom AS CheckInDate,
	|		RoomInventoryPeriods.PeriodDuration AS Duration,
	|		RoomInventoryPeriods.PeriodTo AS CheckOutDate,
	|		RoomInventoryPeriods.CheckInAccountingDate AS CheckInAccountingDate,
	|		RoomInventoryPeriods.CheckOutAccountingDate AS CheckOutAccountingDate,
	|		CASE
	|			WHEN ForeignerRegistryRecords.ForeignerRegistryRecord IS NULL
	|				THEN &qEmptyForeignerRegistryRecord
	|			ELSE ForeignerRegistryRecords.ForeignerRegistryRecord
	|		END AS ForeignerRegistryRecord,
	|		CASE
	|			WHEN ClientDataScans.Ref IS NULL
	|				THEN &qEmptyClientDataScan
	|			ELSE ClientDataScans.Ref
	|		END AS ClientDataScan,
	|		MAX(RoomInventoryPeriods.InHouseGuests) AS InHouseGuests,
	|		MAX(RoomInventoryPeriods.InHouseRooms) AS InHouseRooms,
	|		MAX(RoomInventoryPeriods.InHouseBeds) AS InHouseBeds,
	|		MAX(RoomInventoryPeriods.InHouseAdditionalBeds) AS InHouseAdditionalBeds
	|	FROM
	|		AccumulationRegister.RoomInventory AS RoomInventoryPeriods
	|			LEFT JOIN InformationRegister.AccommodationForeignerRegistryRecords.SliceLast(&qEndOfTime, &qShowFRR) AS ForeignerRegistryRecords
	|			ON RoomInventoryPeriods.Recorder = ForeignerRegistryRecords.Accommodation
	|			LEFT JOIN Document.ClientDataScans AS ClientDataScans
	|			ON RoomInventoryPeriods.Recorder = ClientDataScans.ParentDoc
	|				AND (ClientDataScans.Posted)
	|				AND (&qShowCDS)
	|	WHERE
	|		RoomInventoryPeriods.RecordType = VALUE(AccumulationRecordType.Expense)
	|		AND RoomInventoryPeriods.IsAccommodation = TRUE
	|		AND RoomInventoryPeriods.Hotel IN HIERARCHY(&qHotel)
	|		AND RoomInventoryPeriods.Room IN HIERARCHY(&qRoom)
	|		AND RoomInventoryPeriods.RoomType IN HIERARCHY(&qRoomType)
	|		AND (&qCustomerIsEmpty
	|				OR RoomInventoryPeriods.Customer IN HIERARCHY (&qCustomer))
	|		AND (&qGuestIsEmpty
	|				OR RoomInventoryPeriods.Guest IN HIERARCHY (&qGuest))
	|		AND (ISNULL(RoomInventoryPeriods.AccommodationStatus.IsInHouse, FALSE)
	|				OR NOT &qShowInHouseOnly)
	|		AND (NOT ISNULL(RoomInventoryPeriods.AccommodationStatus.IsInHouse, FALSE)
	|				OR NOT &qShowNotInHouseOnly)
	|		AND (RoomInventoryPeriods.PeriodFrom < &qPeriodTo
	|					AND RoomInventoryPeriods.PeriodTo > &qPeriodFrom
	|					AND &qPeriodCheckType = &qAccommodation
	|				OR RoomInventoryPeriods.PeriodFrom >= &qPeriodFrom
	|					AND RoomInventoryPeriods.PeriodFrom < &qPeriodTo
	|					AND RoomInventoryPeriods.PeriodFrom = RoomInventoryPeriods.CheckInDate
	|					AND (&qPeriodCheckType = &qCheckIn
	|						OR &qPeriodCheckType = &qCheckInOrCheckOut)
	|				OR RoomInventoryPeriods.PeriodTo > &qPeriodFrom
	|					AND RoomInventoryPeriods.PeriodTo <= &qPeriodTo
	|					AND RoomInventoryPeriods.PeriodTo = RoomInventoryPeriods.CheckOutDate
	|					AND (&qPeriodCheckType = &qCheckOut
	|						OR &qPeriodCheckType = &qCheckInOrCheckOut)
	|				OR RoomInventoryPeriods.Recorder.Date >= &qPeriodFrom
	|					AND RoomInventoryPeriods.Recorder.Date < &qPeriodTo
	|					AND &qPeriodCheckType = &qDocDateInPeriod)
	|	
	|	GROUP BY
	|		RoomInventoryPeriods.Recorder,
	|		RoomInventoryPeriods.Room,
	|		RoomInventoryPeriods.RoomType,
	|		RoomInventoryPeriods.AccommodationType,
	|		RoomInventoryPeriods.PeriodFrom,
	|		RoomInventoryPeriods.PeriodDuration,
	|		RoomInventoryPeriods.PeriodTo,
	|		RoomInventoryPeriods.CheckInAccountingDate,
	|		RoomInventoryPeriods.CheckOutAccountingDate,
	|		CASE
	|			WHEN ForeignerRegistryRecords.ForeignerRegistryRecord IS NULL
	|				THEN &qEmptyForeignerRegistryRecord
	|			ELSE ForeignerRegistryRecords.ForeignerRegistryRecord
	|		END,
	|		CASE
	|			WHEN ClientDataScans.Ref IS NULL
	|				THEN &qEmptyClientDataScan
	|			ELSE ClientDataScans.Ref
	|		END) AS RoomInventory
	|		LEFT JOIN (SELECT
	|			GuestSales.ParentDoc AS ParentDoc,
	|			GuestSales.SalesTurnover AS Sales,
	|			GuestSales.RoomRevenueTurnover AS RoomRevenue
	|		FROM
	|			AccumulationRegister.Sales.Turnovers(
	|					&qBegOfPeriodFrom,
	|					&qEndOfPeriodTo,
	|					,
	|					&qShowSales
	|						AND NOT IsCorrection) AS GuestSales) AS GuestPeriodSales
	|		ON RoomInventory.Recorder = GuestPeriodSales.ParentDoc
	|			AND (&qShowSales)
	|		LEFT JOIN (SELECT
	|			AccountsBalance.Folio.ParentDoc AS FolioParentDoc,
	|			SUM(AccountsBalance.SumBalance) AS ClientSumBalance
	|		FROM
	|			AccumulationRegister.Accounts.Balance(
	|					&qEndOfPeriodTo,
	|					&qShowBalances
	|						AND (Folio.Customer = &qEmptyCustomer
	|							OR Folio.Customer <> &qEmptyCustomer
	|								AND Folio.Customer.IsIndividual)) AS AccountsBalance
	|		
	|		GROUP BY
	|			AccountsBalance.Folio.ParentDoc) AS ClientBalances
	|		ON RoomInventory.Recorder = ClientBalances.FolioParentDoc
	|			AND (&qShowBalances)
	|		LEFT JOIN (SELECT
	|			ClientTurnovers.Client AS Client,
	|			ClientTurnovers.GuestsCheckedInTurnover AS NumberOfCheckins
	|		FROM
	|			AccumulationRegister.Sales.Turnovers(
	|					,
	|					&qBegOfPeriodFrom,
	|					PERIOD,
	|					&qNumberOfVisitsIsUsed
	|						AND NOT IsCorrection
	|						AND (&qHotelIsEmpty
	|							OR Hotel IN HIERARCHY (&qHotel))) AS ClientTurnovers) AS ClientTotals
	|		ON RoomInventory.Recorder.Guest = ClientTotals.Client
	|		LEFT JOIN Document.Accommodation.RoomRates AS ExpectedRoomMoves
	|		ON RoomInventory.Recorder = ExpectedRoomMoves.Ref
	|			AND RoomInventory.Recorder.Room <> ExpectedRoomMoves.Room
	|			AND (BEGINOFPERIOD(ExpectedRoomMoves.AccountingDate, DAY) = &qBegOfPeriodFrom)
	|WHERE
	|	(NOT &qShowMainRoomGuestsOnly
	|			OR &qShowMainRoomGuestsOnly
	|				AND RoomInventory.Recorder.AccommodationTemplate <> &qEmptyTemplate)
	|	AND (NOT &qShowRoomMovesOnly
	|			OR &qShowRoomMovesOnly
	|				AND NOT ExpectedRoomMoves.Room IS NULL)
	|{WHERE
	|	RoomInventory.Recorder.* AS Recorder,
	|	RoomInventory.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
	|	RoomInventory.ClientDataScan.* AS ClientDataScan,
	|	RoomInventory.Recorder.Hotel.* AS Hotel,
	|	RoomInventory.RoomType.* AS RoomType,
	|	RoomInventory.Room.* AS Room,
	|	RoomInventory.AccommodationType.* AS AccommodationType,
	|	RoomInventory.Recorder.Customer.* AS Customer,
	|	RoomInventory.Recorder.CustomerType AS CustomerType,
	|	RoomInventory.Recorder.Contract.* AS Contract,
	|	RoomInventory.Recorder.ContactPerson AS ContactPerson,
	|	RoomInventory.Recorder.Agent.* AS Agent,
	|	RoomInventory.Recorder.GuestGroup.* AS GuestGroup,
	|	RoomInventory.Recorder.ParentDoc.* AS ParentDoc,
	|	RoomInventory.Recorder.HotelProduct.* AS HotelProduct,
	|	RoomInventory.Recorder.AccommodationStatus.* AS AccommodationStatus,
	|	RoomInventory.CheckInDate AS CheckInDate,
	|	RoomInventory.Duration AS Duration,
	|	RoomInventory.CheckOutDate AS CheckOutDate,
	|	RoomInventory.CheckInAccountingDate AS CheckInAccountingDate,
	|	RoomInventory.CheckOutAccountingDate AS CheckOutAccountingDate,
	|	(CASE
	|			WHEN &qShowMainRoomGuestsOnly
	|				THEN ISNULL(RoomInventory.Recorder.NumberOfAdults, 0) + ISNULL(RoomInventory.Recorder.NumberOfTeenagers, 0) + ISNULL(RoomInventory.Recorder.NumberOfChildren, 0) + ISNULL(RoomInventory.Recorder.NumberOfInfants, 0)
	|			ELSE RoomInventory.InHouseGuests
	|		END) AS InHouseGuests,
	|	(ISNULL(RoomInventory.Recorder.NumberOfAdults, 0)) AS NumberOfAdults,
	|	(ISNULL(RoomInventory.Recorder.NumberOfTeenagers, 0)) AS NumberOfTeenagers,
	|	(ISNULL(RoomInventory.Recorder.NumberOfChildren, 0)) AS NumberOfChildren,
	|	(ISNULL(RoomInventory.Recorder.NumberOfInfants, 0)) AS NumberOfInfants,
	|	RoomInventory.InHouseRooms AS InHouseRooms,
	|	RoomInventory.InHouseBeds AS InHouseBeds,
	|	RoomInventory.InHouseAdditionalBeds AS InHouseAdditionalBeds,
	|	(ISNULL(GuestPeriodSales.Sales, 0)) AS Sales,
	|	(ISNULL(GuestPeriodSales.RoomRevenue, 0)) AS RoomRevenue,
	|	(ISNULL(ClientBalances.ClientSumBalance, 0)) AS ClientSumBalance,
	|	RoomInventory.Recorder.RoomQuota.* AS RoomQuota,
	|	RoomInventory.Recorder.RoomQuantity AS RoomQuantity,
	|	RoomInventory.Recorder.ClientType.* AS ClientType,
	|	RoomInventory.Recorder.Guest.* AS Guest,
	|	RoomInventory.Recorder.MarketingCode.* AS MarketingCode,
	|	RoomInventory.Recorder.TripPurpose.* AS TripPurpose,
	|	RoomInventory.Recorder.SourceOfBusiness.* AS SourceOfBusiness,
	|	RoomInventory.Recorder.RoomRateType.* AS RoomRateType,
	|	RoomInventory.Recorder.RoomRate.* AS RoomRate,
	|	RoomInventory.Recorder.PricePresentation AS PricePresentation,
	|	RoomInventory.Recorder.DiscountCard.* AS DiscountCard,
	|	RoomInventory.Recorder.DiscountType.* AS DiscountType,
	|	RoomInventory.Recorder.Discount AS Discount,
	|	RoomInventory.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	RoomInventory.Recorder.Car AS Car,
	|	RoomInventory.Recorder.Remarks AS Remarks,
	|	RoomInventory.Recorder.Author.* AS Author,
	|	RoomInventory.Recorder.AgentCommission AS AgentCommission,
	|	RoomInventory.Recorder.AgentCommissionType.* AS AgentCommissionType,
	|	RoomInventory.Recorder.AccommodationTemplate.* AS AccommodationTemplate,
	|	RoomInventory.Recorder.IsMaster AS IsMaster,
	|	ExpectedRoomMoves.Room.* AS RoomTo,
	|	(CASE
	|			WHEN RoomInventory.ForeignerRegistryRecord.MigrationCardDateTo <> &qEmptyDate
	|				THEN DATEDIFF(RoomInventory.ForeignerRegistryRecord.MigrationCardDateTo, RoomInventory.Recorder.CheckOutDate, DAY)
	|			ELSE 0
	|		END) AS MigrationCardDateToDeviance,
	|	(CASE
	|			WHEN RoomInventory.ForeignerRegistryRecord.VisaToDate <> &qEmptyDate
	|				THEN DATEDIFF(RoomInventory.ForeignerRegistryRecord.VisaToDate, RoomInventory.Recorder.CheckOutDate, DAY)
	|			ELSE 0
	|		END) AS VisaToDateDeviance,
	|	(ISNULL(ClientTotals.NumberOfCheckins, 0)) AS NumberOfCheckins,
	|	RoomInventory.Recorder.AccommodationStatus.IsCheckIn AS IsCheckIn,
	|	RoomInventory.Recorder.AccommodationStatus.IsCheckOut AS IsCheckOut,
	|	RoomInventory.Recorder.AccommodationStatus.IsRoomChange AS IsRoomChange,
	|	RoomInventory.Recorder.AccommodationStatus.IsInHouse AS IsInHouse}
	|
	|ORDER BY
	|	Hotel,
	|	Room,
	|	CheckInDate,
	|	Guest
	|{ORDER BY
	|	RoomInventory.Recorder.* AS Recorder,
	|	RoomInventory.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
	|	RoomInventory.ClientDataScan.* AS ClientDataScan,
	|	Customer.* AS Customer,
	|	RoomInventory.Recorder.CustomerType.* AS CustomerType,
	|	RoomInventory.Recorder.Contract.* AS Contract,
	|	RoomInventory.Recorder.Agent.* AS Agent,
	|	GuestGroup.* AS GuestGroup,
	|	Guest.* AS Guest,
	|	RoomInventory.Recorder.MarketingCode.* AS MarketingCode,
	|	RoomInventory.Recorder.TripPurpose.* AS TripPurpose,
	|	RoomInventory.Recorder.SourceOfBusiness.* AS SourceOfBusiness,
	|	RoomRate.* AS RoomRate,
	|	RoomInventory.Recorder.RoomRateType.* AS RoomRateType,
	|	RoomInventory.Recorder.DiscountCard.* AS DiscountCard,
	|	RoomInventory.Recorder.DiscountType.* AS DiscountType,
	|	RoomInventory.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	Room.* AS Room,
	|	RoomType.* AS RoomType,
	|	AccommodationType.* AS AccommodationType,
	|	RoomTo.* AS RoomTo,
	|	Hotel.* AS Hotel,
	|	RoomInventory.Recorder.PointInTime AS PointInTime,
	|	CheckInDate AS CheckInDate,
	|	Duration AS Duration,
	|	CheckOutDate AS CheckOutDate,
	|	RoomInventory.Recorder.RoomRateType.* AS RoomRateType,
	|	RoomInventory.Recorder.AccommodationTemplate.* AS AccommodationTemplate,
	|	RoomRate.* AS RoomRate,
	|	PricePresentation AS PricePresentation,
	|	RoomInventory.Recorder.Author.* AS Author,
	|	InHouseGuests AS InHouseGuests,
	|	NumberOfAdults,
	|	NumberOfTeenagers,
	|	NumberOfChildren,
	|	NumberOfInfants,
	|	InHouseRooms AS InHouseRooms,
	|	InHouseBeds AS InHouseBeds,
	|	InHouseAdditionalBeds AS InHouseAdditionalBeds,
	|	RoomInventory.CheckInAccountingDate AS CheckInAccountingDate,
	|	RoomInventory.CheckOutAccountingDate AS CheckOutAccountingDate,
	|	(HOUR(RoomInventory.Recorder.CheckInDate)) AS CheckInHour,
	|	(DAY(RoomInventory.Recorder.CheckInDate)) AS CheckInDay,
	|	(WEEK(RoomInventory.Recorder.CheckInDate)) AS CheckInWeek,
	|	(MONTH(RoomInventory.Recorder.CheckInDate)) AS CheckInMonth,
	|	(QUARTER(RoomInventory.Recorder.CheckInDate)) AS CheckInQuarter,
	|	(YEAR(RoomInventory.Recorder.CheckInDate)) AS CheckInYear,
	|	Sales,
	|	RoomRevenue,
	|	ClientSumBalance,
	|	NumberOfCheckins,
	|	RoomInventory.Recorder.RoomQuota.* AS RoomQuota}
	|TOTALS
	|	SUM(InHouseGuests),
	|	SUM(NumberOfAdults),
	|	SUM(NumberOfTeenagers),
	|	SUM(NumberOfChildren),
	|	SUM(NumberOfInfants),
	|	SUM(InHouseRooms),
	|	SUM(InHouseBeds),
	|	SUM(InHouseAdditionalBeds),
	|	SUM(HotelProductSum),
	|	SUM(Sales),
	|	SUM(RoomRevenue),
	|	SUM(ClientSumBalance)
	|BY
	|	OVERALL,
	|	Hotel,
	|	Room
	|{TOTALS BY
	|	Hotel.* AS Hotel,
	|	RoomInventory.CheckInAccountingDate AS CheckInAccountingDate,
	|	RoomInventory.CheckOutAccountingDate AS CheckOutAccountingDate,
	|	(HOUR(RoomInventory.Recorder.CheckInDate)) AS CheckInHour,
	|	(DAY(RoomInventory.Recorder.CheckInDate)) AS CheckInDay,
	|	(WEEK(RoomInventory.Recorder.CheckInDate)) AS CheckInWeek,
	|	(MONTH(RoomInventory.Recorder.CheckInDate)) AS CheckInMonth,
	|	(QUARTER(RoomInventory.Recorder.CheckInDate)) AS CheckInQuarter,
	|	(YEAR(RoomInventory.Recorder.CheckInDate)) AS CheckInYear,
	|	RoomType.* AS RoomType,
	|	Room.* AS Room,
	|	RoomTo.* AS RoomTo,
	|	AccommodationType.* AS AccommodationType,
	|	Customer.* AS Customer,
	|	RoomInventory.Recorder.CustomerType.* AS CustomerType,
	|	RoomInventory.Recorder.Contract.* AS Contract,
	|	RoomInventory.Recorder.ContactPerson AS ContactPerson,
	|	RoomInventory.Recorder.Agent.* AS Agent,
	|	GuestGroup.* AS GuestGroup,
	|	RoomInventory.Recorder.HotelProduct.* AS HotelProduct,
	|	AccommodationStatus.* AS AccommodationStatus,
	|	RoomInventory.Recorder.RoomQuota.* AS RoomQuota,
	|	RoomInventory.Recorder.ClientType.* AS ClientType,
	|	RoomInventory.Recorder.MarketingCode.* AS MarketingCode,
	|	RoomInventory.Recorder.TripPurpose.* AS TripPurpose,
	|	RoomInventory.Recorder.SourceOfBusiness.* AS SourceOfBusiness,
	|	RoomInventory.Recorder.RoomRateType.* AS RoomRateType,
	|	RoomInventory.Recorder.AccommodationTemplate.* AS AccommodationTemplate,
	|	RoomRate.* AS RoomRate,
	|	PricePresentation AS PricePresentation,
	|	RoomInventory.Recorder.DiscountCard.* AS DiscountCard,
	|	RoomInventory.Recorder.DiscountType.* AS DiscountType,
	|	RoomInventory.Recorder.Author.* AS Author,
	|	RoomInventory.Recorder.* AS Recorder,
	|	RoomInventory.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
	|	RoomInventory.ClientDataScan.* AS ClientDataScan,
	|	RoomInventory.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	NumberOfCheckins}";
	#КонецВставки
	#Удаление
	QueryText = 
	"SELECT
	|	RoomInventory.Recorder.Hotel AS Hotel,
	|	RoomInventory.Room AS Room,
	|	RoomInventory.Recorder.Customer AS Customer,
	|	RoomInventory.Recorder.AccommodationStatus AS AccommodationStatus,
	|	RoomInventory.Recorder.Guest AS Guest,
	|	RoomInventory.CheckInDate AS CheckInDate,
	|	RoomInventory.Duration AS Duration,
	|	RoomInventory.CheckOutDate AS CheckOutDate,
	|	RoomInventory.RoomType AS RoomType,
	|	RoomInventory.AccommodationType AS AccommodationType,
	|	RoomInventory.Recorder.RoomRate AS RoomRate,
	|	RoomInventory.Recorder.Remarks AS Remarks,
	|	RoomInventory.Recorder.GuestGroup AS GuestGroup,
	|	CASE
	|		WHEN &qShowMainRoomGuestsOnly
	|			THEN ISNULL(RoomInventory.Recorder.NumberOfAdults, 0) + ISNULL(RoomInventory.Recorder.NumberOfTeenagers, 0) + ISNULL(RoomInventory.Recorder.NumberOfChildren, 0) + ISNULL(RoomInventory.Recorder.NumberOfInfants, 0)
	|		ELSE RoomInventory.InHouseGuests
	|	END AS InHouseGuests,
	|	ISNULL(RoomInventory.Recorder.NumberOfAdults, 0) AS NumberOfAdults,
	|	ISNULL(RoomInventory.Recorder.NumberOfTeenagers, 0) AS NumberOfTeenagers,
	|	ISNULL(RoomInventory.Recorder.NumberOfChildren, 0) AS NumberOfChildren,
	|	ISNULL(RoomInventory.Recorder.NumberOfInfants, 0) AS NumberOfInfants,
	|	RoomInventory.InHouseRooms AS InHouseRooms,
	|	RoomInventory.InHouseBeds AS InHouseBeds,
	|	RoomInventory.InHouseAdditionalBeds AS InHouseAdditionalBeds,
	|	RoomInventory.Recorder.HotelProduct.Sum AS HotelProductSum,
	|	RoomInventory.Recorder.PricePresentation AS PricePresentation,
	|	ExpectedRoomMoves.Room AS RoomTo,
	|	ISNULL(GuestPeriodSales.Sales, 0) AS Sales,
	|	ISNULL(GuestPeriodSales.RoomRevenue, 0) AS RoomRevenue,
	|	ISNULL(ClientBalances.ClientSumBalance, 0) AS ClientSumBalance,
	|	ISNULL(ClientTotals.NumberOfCheckins, 0) AS NumberOfCheckins
	|{SELECT
	|	Hotel.*,
	|	Room.*,
	|	RoomInventory.Recorder.CustomerType.* AS CustomerType,
	|	Customer.*,
	|	RoomInventory.Recorder.Contract.* AS Contract,
	|	RoomInventory.Recorder.ContactPerson AS ContactPerson,
	|	RoomInventory.Recorder.Agent.* AS Agent,
	|	RoomInventory.Recorder.ClientType.* AS ClientType,
	|	Guest.*,
	|	CheckInDate,
	|	Duration,
	|	CheckOutDate,
	|	RoomInventory.CheckInAccountingDate AS CheckInAccountingDate,
	|	RoomInventory.CheckOutAccountingDate AS CheckOutAccountingDate,
	|	(HOUR(RoomInventory.Recorder.CheckInDate)) AS CheckInHour,
	|	(DAY(RoomInventory.Recorder.CheckInDate)) AS CheckInDay,
	|	(WEEK(RoomInventory.Recorder.CheckInDate)) AS CheckInWeek,
	|	(MONTH(RoomInventory.Recorder.CheckInDate)) AS CheckInMonth,
	|	(QUARTER(RoomInventory.Recorder.CheckInDate)) AS CheckInQuarter,
	|	(YEAR(RoomInventory.Recorder.CheckInDate)) AS CheckInYear,
	|	RoomType.*,
	|	AccommodationType.*,
	|	RoomInventory.Recorder.RoomRateType.* AS RoomRateType,
	|	RoomInventory.Recorder.AccommodationTemplate.* AS AccommodationTemplate,
	|	RoomRate.*,
	|	PricePresentation,
	|	RoomInventory.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	InHouseGuests,
	|	NumberOfAdults,
	|	NumberOfTeenagers,
	|	NumberOfChildren,
	|	NumberOfInfants,
	|	InHouseRooms,
	|	InHouseBeds,
	|	InHouseAdditionalBeds,
	|	Remarks,
	|	RoomInventory.Recorder.Car AS Car,
	|	GuestGroup.*,
	|	AccommodationStatus.*,
	|	RoomInventory.Recorder.IsMaster AS IsMaster,
	|	RoomInventory.Recorder.HotelProduct.* AS HotelProduct,
	|	RoomInventory.Recorder.RoomQuota.* AS RoomQuota,
	|	RoomInventory.Recorder.MarketingCode.* AS MarketingCode,
	|	RoomInventory.Recorder.TripPurpose.* AS TripPurpose,
	|	RoomInventory.Recorder.SourceOfBusiness.* AS SourceOfBusiness,
	|	RoomInventory.Recorder.DiscountCard.* AS DiscountCard,
	|	RoomInventory.Recorder.DiscountType.* AS DiscountType,
	|	RoomInventory.Recorder.Discount AS Discount,
	|	RoomInventory.Recorder.AgentCommission AS AgentCommission,
	|	RoomInventory.Recorder.AgentCommissionType AS AgentCommissionType,
	|	RoomInventory.Recorder.RoomQuantity AS RoomQuantity,
	|	RoomInventory.Recorder.NumberOfBedsPerRoom AS NumberOfBedsPerRoom,
	|	RoomInventory.Recorder.NumberOfPersonsPerRoom AS NumberOfPersonsPerRoom,
	|	HotelProductSum,
	|	RoomInventory.Recorder.HotelProduct.Currency.* AS HotelProductCurrency,
	|	RoomInventory.Recorder.ParentDoc.* AS ParentDoc,
	|	RoomInventory.Recorder.Author.* AS Author,
	|	RoomInventory.Recorder.* AS Recorder,
	|	RoomTo.*,
	|	RoomInventory.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
	|	RoomInventory.ClientDataScan.* AS ClientDataScan,
	|	(CASE
	|			WHEN RoomInventory.ForeignerRegistryRecord.MigrationCardDateTo <> &qEmptyDate
	|				THEN DATEDIFF(RoomInventory.ForeignerRegistryRecord.MigrationCardDateTo, RoomInventory.Recorder.CheckOutDate, DAY)
	|			ELSE 0
	|		END) AS MigrationCardDateToDeviance,
	|	(CASE
	|			WHEN RoomInventory.ForeignerRegistryRecord.VisaToDate <> &qEmptyDate
	|				THEN DATEDIFF(RoomInventory.ForeignerRegistryRecord.VisaToDate, RoomInventory.Recorder.CheckOutDate, DAY)
	|			ELSE 0
	|		END) AS VisaToDateDeviance,
	|	RoomInventory.Recorder.PointInTime AS PointInTime,
	|	Sales,
	|	RoomRevenue,
	|	ClientSumBalance,
	|	NumberOfCheckins,
	|	(NULL) AS EmptyColumn}
	|FROM
	|	(SELECT
	|		RoomInventoryPeriods.Recorder AS Recorder,
	|		RoomInventoryPeriods.Room AS Room,
	|		RoomInventoryPeriods.RoomType AS RoomType,
	|		RoomInventoryPeriods.AccommodationType AS AccommodationType,
	|		RoomInventoryPeriods.PeriodFrom AS CheckInDate,
	|		RoomInventoryPeriods.PeriodDuration AS Duration,
	|		RoomInventoryPeriods.PeriodTo AS CheckOutDate,
	|		RoomInventoryPeriods.CheckInAccountingDate AS CheckInAccountingDate,
	|		RoomInventoryPeriods.CheckOutAccountingDate AS CheckOutAccountingDate,
	|		CASE
	|			WHEN ForeignerRegistryRecords.ForeignerRegistryRecord IS NULL
	|				THEN &qEmptyForeignerRegistryRecord
	|			ELSE ForeignerRegistryRecords.ForeignerRegistryRecord
	|		END AS ForeignerRegistryRecord,
	|		CASE
	|			WHEN ClientDataScans.Ref IS NULL
	|				THEN &qEmptyClientDataScan
	|			ELSE ClientDataScans.Ref
	|		END AS ClientDataScan,
	|		MAX(RoomInventoryPeriods.InHouseGuests) AS InHouseGuests,
	|		MAX(RoomInventoryPeriods.InHouseRooms) AS InHouseRooms,
	|		MAX(RoomInventoryPeriods.InHouseBeds) AS InHouseBeds,
	|		MAX(RoomInventoryPeriods.InHouseAdditionalBeds) AS InHouseAdditionalBeds
	|	FROM
	|		AccumulationRegister.RoomInventory AS RoomInventoryPeriods
	|			LEFT JOIN InformationRegister.AccommodationForeignerRegistryRecords.SliceLast(&qEndOfTime, &qShowFRR) AS ForeignerRegistryRecords
	|			ON RoomInventoryPeriods.Recorder = ForeignerRegistryRecords.Accommodation
	|			LEFT JOIN Document.ClientDataScans AS ClientDataScans
	|			ON RoomInventoryPeriods.Recorder = ClientDataScans.ParentDoc
	|				AND (ClientDataScans.Posted)
	|				AND (&qShowCDS)
	|	WHERE
	|		RoomInventoryPeriods.RecordType = VALUE(AccumulationRecordType.Expense)
	|		AND RoomInventoryPeriods.IsAccommodation = TRUE
	|		AND RoomInventoryPeriods.Hotel IN HIERARCHY(&qHotel)
	|		AND RoomInventoryPeriods.Room IN HIERARCHY(&qRoom)
	|		AND RoomInventoryPeriods.RoomType IN HIERARCHY(&qRoomType)
	|		AND (&qCustomerIsEmpty
	|				OR RoomInventoryPeriods.Customer IN HIERARCHY (&qCustomer))
	|		AND (&qGuestIsEmpty
	|				OR RoomInventoryPeriods.Guest IN HIERARCHY (&qGuest))
	|		AND (ISNULL(RoomInventoryPeriods.AccommodationStatus.IsInHouse, FALSE)
	|				OR NOT &qShowInHouseOnly)
	|		AND (NOT ISNULL(RoomInventoryPeriods.AccommodationStatus.IsInHouse, FALSE)
	|				OR NOT &qShowNotInHouseOnly)
	|		AND (RoomInventoryPeriods.PeriodFrom < &qPeriodTo
	|					AND RoomInventoryPeriods.PeriodTo > &qPeriodFrom
	|					AND &qPeriodCheckType = &qAccommodation
	|				OR RoomInventoryPeriods.PeriodFrom >= &qPeriodFrom
	|					AND RoomInventoryPeriods.PeriodFrom < &qPeriodTo
	|					AND RoomInventoryPeriods.PeriodFrom = RoomInventoryPeriods.CheckInDate
	|					AND (&qPeriodCheckType = &qCheckIn
	|						OR &qPeriodCheckType = &qCheckInOrCheckOut)
	|				OR RoomInventoryPeriods.PeriodTo > &qPeriodFrom
	|					AND RoomInventoryPeriods.PeriodTo <= &qPeriodTo
	|					AND RoomInventoryPeriods.PeriodTo = RoomInventoryPeriods.CheckOutDate
	|					AND (&qPeriodCheckType = &qCheckOut
	|						OR &qPeriodCheckType = &qCheckInOrCheckOut)
	|				OR RoomInventoryPeriods.Recorder.Date >= &qPeriodFrom
	|					AND RoomInventoryPeriods.Recorder.Date < &qPeriodTo
	|					AND &qPeriodCheckType = &qDocDateInPeriod)
	|	
	|	GROUP BY
	|		RoomInventoryPeriods.Recorder,
	|		RoomInventoryPeriods.Room,
	|		RoomInventoryPeriods.RoomType,
	|		RoomInventoryPeriods.AccommodationType,
	|		RoomInventoryPeriods.PeriodFrom,
	|		RoomInventoryPeriods.PeriodDuration,
	|		RoomInventoryPeriods.PeriodTo,
	|		RoomInventoryPeriods.CheckInAccountingDate,
	|		RoomInventoryPeriods.CheckOutAccountingDate,
	|		CASE
	|			WHEN ForeignerRegistryRecords.ForeignerRegistryRecord IS NULL
	|				THEN &qEmptyForeignerRegistryRecord
	|			ELSE ForeignerRegistryRecords.ForeignerRegistryRecord
	|		END,
	|		CASE
	|			WHEN ClientDataScans.Ref IS NULL
	|				THEN &qEmptyClientDataScan
	|			ELSE ClientDataScans.Ref
	|		END) AS RoomInventory
	|		LEFT JOIN (SELECT
	|			GuestSales.ParentDoc AS ParentDoc,
	|			GuestSales.SalesTurnover AS Sales,
	|			GuestSales.RoomRevenueTurnover AS RoomRevenue
	|		FROM
	|			AccumulationRegister.Sales.Turnovers(
	|					&qBegOfPeriodFrom,
	|					&qEndOfPeriodTo,
	|					,
	|					&qShowSales
	|						AND NOT IsCorrection) AS GuestSales) AS GuestPeriodSales
	|		ON RoomInventory.Recorder = GuestPeriodSales.ParentDoc
	|			AND (&qShowSales)
	|		LEFT JOIN (SELECT
	|			AccountsBalance.Folio.ParentDoc AS FolioParentDoc,
	|			SUM(AccountsBalance.SumBalance) AS ClientSumBalance
	|		FROM
	|			AccumulationRegister.Accounts.Balance(
	|					&qEndOfPeriodTo,
	|					&qShowBalances
	|						AND (Folio.Customer = &qEmptyCustomer
	|							OR Folio.Customer <> &qEmptyCustomer
	|								AND Folio.Customer.IsIndividual)) AS AccountsBalance
	|		
	|		GROUP BY
	|			AccountsBalance.Folio.ParentDoc) AS ClientBalances
	|		ON RoomInventory.Recorder = ClientBalances.FolioParentDoc
	|			AND (&qShowBalances)
	|		LEFT JOIN (SELECT
	|			ClientTurnovers.Client AS Client,
	|			ClientTurnovers.GuestsCheckedInTurnover AS NumberOfCheckins
	|		FROM
	|			AccumulationRegister.Sales.Turnovers(
	|					,
	|					&qBegOfPeriodFrom,
	|					PERIOD,
	|					&qNumberOfVisitsIsUsed
	|						AND NOT IsCorrection
	|						AND (&qHotelIsEmpty
	|							OR Hotel IN HIERARCHY (&qHotel))) AS ClientTurnovers) AS ClientTotals
	|		ON RoomInventory.Recorder.Guest = ClientTotals.Client
	|		LEFT JOIN Document.Accommodation.RoomRates AS ExpectedRoomMoves
	|		ON RoomInventory.Recorder = ExpectedRoomMoves.Ref
	|			AND RoomInventory.Recorder.Room <> ExpectedRoomMoves.Room
	|			AND (BEGINOFPERIOD(ExpectedRoomMoves.AccountingDate, DAY) = &qBegOfPeriodFrom)
	|WHERE
	|	(NOT &qShowMainRoomGuestsOnly
	|			OR &qShowMainRoomGuestsOnly
	|				AND RoomInventory.Recorder.AccommodationTemplate <> &qEmptyTemplate)
	|	AND (NOT &qShowRoomMovesOnly
	|			OR &qShowRoomMovesOnly
	|				AND NOT ExpectedRoomMoves.Room IS NULL)
	|{WHERE
	|	RoomInventory.Recorder.* AS Recorder,
	|	RoomInventory.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
	|	RoomInventory.ClientDataScan.* AS ClientDataScan,
	|	RoomInventory.Recorder.Hotel.* AS Hotel,
	|	RoomInventory.RoomType.* AS RoomType,
	|	RoomInventory.Room.* AS Room,
	|	RoomInventory.AccommodationType.* AS AccommodationType,
	|	RoomInventory.Recorder.Customer.* AS Customer,
	|	RoomInventory.Recorder.CustomerType AS CustomerType,
	|	RoomInventory.Recorder.Contract.* AS Contract,
	|	RoomInventory.Recorder.ContactPerson AS ContactPerson,
	|	RoomInventory.Recorder.Agent.* AS Agent,
	|	RoomInventory.Recorder.GuestGroup.* AS GuestGroup,
	|	RoomInventory.Recorder.ParentDoc.* AS ParentDoc,
	|	RoomInventory.Recorder.HotelProduct.* AS HotelProduct,
	|	RoomInventory.Recorder.AccommodationStatus.* AS AccommodationStatus,
	|	RoomInventory.CheckInDate AS CheckInDate,
	|	RoomInventory.Duration AS Duration,
	|	RoomInventory.CheckOutDate AS CheckOutDate,
	|	RoomInventory.CheckInAccountingDate AS CheckInAccountingDate,
	|	RoomInventory.CheckOutAccountingDate AS CheckOutAccountingDate,
	|	(CASE
	|			WHEN &qShowMainRoomGuestsOnly
	|				THEN ISNULL(RoomInventory.Recorder.NumberOfAdults, 0) + ISNULL(RoomInventory.Recorder.NumberOfTeenagers, 0) + ISNULL(RoomInventory.Recorder.NumberOfChildren, 0) + ISNULL(RoomInventory.Recorder.NumberOfInfants, 0)
	|			ELSE RoomInventory.InHouseGuests
	|		END) AS InHouseGuests,
	|	(ISNULL(RoomInventory.Recorder.NumberOfAdults, 0)) AS NumberOfAdults,
	|	(ISNULL(RoomInventory.Recorder.NumberOfTeenagers, 0)) AS NumberOfTeenagers,
	|	(ISNULL(RoomInventory.Recorder.NumberOfChildren, 0)) AS NumberOfChildren,
	|	(ISNULL(RoomInventory.Recorder.NumberOfInfants, 0)) AS NumberOfInfants,
	|	RoomInventory.InHouseRooms AS InHouseRooms,
	|	RoomInventory.InHouseBeds AS InHouseBeds,
	|	RoomInventory.InHouseAdditionalBeds AS InHouseAdditionalBeds,
	|	(ISNULL(GuestPeriodSales.Sales, 0)) AS Sales,
	|	(ISNULL(GuestPeriodSales.RoomRevenue, 0)) AS RoomRevenue,
	|	(ISNULL(ClientBalances.ClientSumBalance, 0)) AS ClientSumBalance,
	|	RoomInventory.Recorder.RoomQuota.* AS RoomQuota,
	|	RoomInventory.Recorder.RoomQuantity AS RoomQuantity,
	|	RoomInventory.Recorder.ClientType.* AS ClientType,
	|	RoomInventory.Recorder.Guest.* AS Guest,
	|	RoomInventory.Recorder.MarketingCode.* AS MarketingCode,
	|	RoomInventory.Recorder.TripPurpose.* AS TripPurpose,
	|	RoomInventory.Recorder.SourceOfBusiness.* AS SourceOfBusiness,
	|	RoomInventory.Recorder.RoomRateType.* AS RoomRateType,
	|	RoomInventory.Recorder.RoomRate.* AS RoomRate,
	|	RoomInventory.Recorder.PricePresentation AS PricePresentation,
	|	RoomInventory.Recorder.DiscountCard.* AS DiscountCard,
	|	RoomInventory.Recorder.DiscountType.* AS DiscountType,
	|	RoomInventory.Recorder.Discount AS Discount,
	|	RoomInventory.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	RoomInventory.Recorder.Car AS Car,
	|	RoomInventory.Recorder.Remarks AS Remarks,
	|	RoomInventory.Recorder.Author.* AS Author,
	|	RoomInventory.Recorder.AgentCommission AS AgentCommission,
	|	RoomInventory.Recorder.AgentCommissionType.* AS AgentCommissionType,
	|	RoomInventory.Recorder.AccommodationTemplate.* AS AccommodationTemplate,
	|	RoomInventory.Recorder.IsMaster AS IsMaster,
	|	ExpectedRoomMoves.Room.* AS RoomTo,
	|	(CASE
	|			WHEN RoomInventory.ForeignerRegistryRecord.MigrationCardDateTo <> &qEmptyDate
	|				THEN DATEDIFF(RoomInventory.ForeignerRegistryRecord.MigrationCardDateTo, RoomInventory.Recorder.CheckOutDate, DAY)
	|			ELSE 0
	|		END) AS MigrationCardDateToDeviance,
	|	(CASE
	|			WHEN RoomInventory.ForeignerRegistryRecord.VisaToDate <> &qEmptyDate
	|				THEN DATEDIFF(RoomInventory.ForeignerRegistryRecord.VisaToDate, RoomInventory.Recorder.CheckOutDate, DAY)
	|			ELSE 0
	|		END) AS VisaToDateDeviance,
	|	(ISNULL(ClientTotals.NumberOfCheckins, 0)) AS NumberOfCheckins,
	|	RoomInventory.Recorder.AccommodationStatus.IsCheckIn AS IsCheckIn,
	|	RoomInventory.Recorder.AccommodationStatus.IsCheckOut AS IsCheckOut,
	|	RoomInventory.Recorder.AccommodationStatus.IsRoomChange AS IsRoomChange,
	|	RoomInventory.Recorder.AccommodationStatus.IsInHouse AS IsInHouse}
	|
	|ORDER BY
	|	Hotel,
	|	Room,
	|	CheckInDate,
	|	Guest
	|{ORDER BY
	|	RoomInventory.Recorder.* AS Recorder,
	|	RoomInventory.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
	|	RoomInventory.ClientDataScan.* AS ClientDataScan,
	|	Customer.* AS Customer,
	|	RoomInventory.Recorder.CustomerType.* AS CustomerType,
	|	RoomInventory.Recorder.Contract.* AS Contract,
	|	RoomInventory.Recorder.Agent.* AS Agent,
	|	GuestGroup.* AS GuestGroup,
	|	Guest.* AS Guest,
	|	RoomInventory.Recorder.MarketingCode.* AS MarketingCode,
	|	RoomInventory.Recorder.TripPurpose.* AS TripPurpose,
	|	RoomInventory.Recorder.SourceOfBusiness.* AS SourceOfBusiness,
	|	RoomRate.* AS RoomRate,
	|	RoomInventory.Recorder.RoomRateType.* AS RoomRateType,
	|	RoomInventory.Recorder.DiscountCard.* AS DiscountCard,
	|	RoomInventory.Recorder.DiscountType.* AS DiscountType,
	|	RoomInventory.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	Room.* AS Room,
	|	RoomType.* AS RoomType,
	|	AccommodationType.* AS AccommodationType,
	|	RoomTo.* AS RoomTo,
	|	Hotel.* AS Hotel,
	|	RoomInventory.Recorder.PointInTime AS PointInTime,
	|	CheckInDate AS CheckInDate,
	|	Duration AS Duration,
	|	CheckOutDate AS CheckOutDate,
	|	RoomInventory.Recorder.RoomRateType.* AS RoomRateType,
	|	RoomInventory.Recorder.AccommodationTemplate.* AS AccommodationTemplate,
	|	RoomRate.* AS RoomRate,
	|	PricePresentation AS PricePresentation,
	|	RoomInventory.Recorder.Author.* AS Author,
	|	InHouseGuests AS InHouseGuests,
	|	NumberOfAdults,
	|	NumberOfTeenagers,
	|	NumberOfChildren,
	|	NumberOfInfants,
	|	InHouseRooms AS InHouseRooms,
	|	InHouseBeds AS InHouseBeds,
	|	InHouseAdditionalBeds AS InHouseAdditionalBeds,
	|	RoomInventory.CheckInAccountingDate AS CheckInAccountingDate,
	|	RoomInventory.CheckOutAccountingDate AS CheckOutAccountingDate,
	|	(HOUR(RoomInventory.Recorder.CheckInDate)) AS CheckInHour,
	|	(DAY(RoomInventory.Recorder.CheckInDate)) AS CheckInDay,
	|	(WEEK(RoomInventory.Recorder.CheckInDate)) AS CheckInWeek,
	|	(MONTH(RoomInventory.Recorder.CheckInDate)) AS CheckInMonth,
	|	(QUARTER(RoomInventory.Recorder.CheckInDate)) AS CheckInQuarter,
	|	(YEAR(RoomInventory.Recorder.CheckInDate)) AS CheckInYear,
	|	Sales,
	|	RoomRevenue,
	|	ClientSumBalance,
	|	NumberOfCheckins,
	|	RoomInventory.Recorder.RoomQuota.* AS RoomQuota}
	|TOTALS
	|	SUM(InHouseGuests),
	|	SUM(NumberOfAdults),
	|	SUM(NumberOfTeenagers),
	|	SUM(NumberOfChildren),
	|	SUM(NumberOfInfants),
	|	SUM(InHouseRooms),
	|	SUM(InHouseBeds),
	|	SUM(InHouseAdditionalBeds),
	|	SUM(HotelProductSum),
	|	SUM(Sales),
	|	SUM(RoomRevenue),
	|	SUM(ClientSumBalance)
	|BY
	|	OVERALL,
	|	Hotel,
	|	Room
	|{TOTALS BY
	|	Hotel.* AS Hotel,
	|	RoomInventory.CheckInAccountingDate AS CheckInAccountingDate,
	|	RoomInventory.CheckOutAccountingDate AS CheckOutAccountingDate,
	|	(HOUR(RoomInventory.Recorder.CheckInDate)) AS CheckInHour,
	|	(DAY(RoomInventory.Recorder.CheckInDate)) AS CheckInDay,
	|	(WEEK(RoomInventory.Recorder.CheckInDate)) AS CheckInWeek,
	|	(MONTH(RoomInventory.Recorder.CheckInDate)) AS CheckInMonth,
	|	(QUARTER(RoomInventory.Recorder.CheckInDate)) AS CheckInQuarter,
	|	(YEAR(RoomInventory.Recorder.CheckInDate)) AS CheckInYear,
	|	RoomType.* AS RoomType,
	|	Room.* AS Room,
	|	RoomTo.* AS RoomTo,
	|	AccommodationType.* AS AccommodationType,
	|	Customer.* AS Customer,
	|	RoomInventory.Recorder.CustomerType.* AS CustomerType,
	|	RoomInventory.Recorder.Contract.* AS Contract,
	|	RoomInventory.Recorder.ContactPerson AS ContactPerson,
	|	RoomInventory.Recorder.Agent.* AS Agent,
	|	GuestGroup.* AS GuestGroup,
	|	RoomInventory.Recorder.HotelProduct.* AS HotelProduct,
	|	AccommodationStatus.* AS AccommodationStatus,
	|	RoomInventory.Recorder.RoomQuota.* AS RoomQuota,
	|	RoomInventory.Recorder.ClientType.* AS ClientType,
	|	RoomInventory.Recorder.MarketingCode.* AS MarketingCode,
	|	RoomInventory.Recorder.TripPurpose.* AS TripPurpose,
	|	RoomInventory.Recorder.SourceOfBusiness.* AS SourceOfBusiness,
	|	RoomInventory.Recorder.RoomRateType.* AS RoomRateType,
	|	RoomInventory.Recorder.AccommodationTemplate.* AS AccommodationTemplate,
	|	RoomRate.* AS RoomRate,
	|	PricePresentation AS PricePresentation,
	|	RoomInventory.Recorder.DiscountCard.* AS DiscountCard,
	|	RoomInventory.Recorder.DiscountType.* AS DiscountType,
	|	RoomInventory.Recorder.Author.* AS Author,
	|	RoomInventory.Recorder.* AS Recorder,
	|	RoomInventory.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
	|	RoomInventory.ClientDataScan.* AS ClientDataScan,
	|	RoomInventory.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	NumberOfCheckins}";
	#КонецУдаления
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();

	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);

	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("en='Room occupation history';de='Zimmerbesatzungsgeschichte';ru='История заселения номеров'");

	// Fill report builder fields presentations from the report template
	cmFillReportAttributesPresentations(ThisObject);

	// Reset report builder template
	ReportBuilder.Template = Undefined;EndProcedure
