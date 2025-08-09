/**
 * Locale System for Pizza Job
 * Handles multi-language support for Hebrew and English
 */

Locales = {}

-- English Locale
Locales['en'] = {
    -- Job Actions
    ['start_job'] = 'Start Pizza Job',
    ['stop_job'] = 'Stop Pizza Job',
    ['make_pizzas'] = 'Make Pizzas',
    ['deliver_pizza'] = 'Deliver Pizza',
    ['store_pizzas'] = 'Store Pizzas (%d stored)',
    ['take_pizza'] = 'Take Pizza (%d available)',
    ['return_pizza'] = 'Return Pizza',
    
    -- Notifications - Job Status
    ['job_started'] = 'Pizza delivery job started!',
    ['job_stopped'] = 'Pizza delivery job stopped!',
    ['not_working'] = "You're not currently working!",
    ['new_delivery'] = 'You have a new delivery!',
    ['pizza_delivered'] = 'Pizza Delivered. Please wait for your next delivery!',
    
    -- Notifications - Pizza Making
    ['pizza_made_success'] = 'Pizza made successfully! +1 Pizza Delivery Box',
    ['pizza_making_started_kitchen'] = 'Started making pizzas! Move away from the kitchen to stop',
    ['pizza_making_started_menu'] = 'Started making pizzas! Press [ESC] or return to menu to stop',
    ['pizza_making_stopped'] = 'Stopped making pizzas',
    ['pizza_making_too_far'] = 'You moved too far from the kitchen! Pizza making stopped.',
    ['need_pizza_kitchen'] = 'You need to be at the pizza kitchen to make pizzas!',
    
    -- Notifications - Vehicle & Delivery
    ['vehicle_spawned'] = 'Vehicle spawned and target added!',
    ['no_delivery_vehicle'] = 'No delivery vehicle found!',
    ['need_pizza_first'] = 'You need to take a pizza from the vehicle first!',
    ['pizza_already_delivered'] = 'Pizza already delivered!',
    ['took_pizza_from_vehicle'] = 'You took a pizza from the vehicle!',
    ['returned_pizza_to_vehicle'] = 'You returned the pizza to the vehicle!',
    ['no_pizza_to_return'] = "You don't have a pizza to return!",
    ['need_closer_to_vehicle'] = 'You need to be closer to the vehicle!',
    ['no_pizzas_in_vehicle'] = 'No pizzas stored in the vehicle!',
    ['cannot_store_pizzas'] = 'Cannot store pizzas right now!',
    
    -- Notifications - Inventory & Items
    ['need_pizza_boxes_to_store'] = 'You need pizza delivery boxes to store!',
    ['no_pizza_boxes'] = "You don't have any pizza delivery boxes!",
    ['not_enough_pizza_boxes'] = "You don't have enough pizza delivery boxes!",
    ['stored_pizzas_success'] = 'Stored %d pizzas in the vehicle!',
    ['invalid_quantity'] = 'Invalid quantity!',
    ['no_quantity_selected'] = 'No quantity selected!',
    ['pizza_boxes_count'] = 'You have %d pizza delivery boxes',
    
    -- Notifications - Payment & XP
    ['no_deliveries_no_pay'] = "You didn't complete any deliveries, so you weren't paid.",
    ['must_return_vehicle'] = 'You must return your work vehicle to get paid.',
    ['received_money'] = 'You received $%d',
    ['received_delivery_payment'] = 'You received $%d for your delivery!',
    ['pizza_made_xp'] = 'Pizza made! +%d XP | Level %d %s (%d XP)',
    ['pizza_made_money'] = 'Pizza made! +$%d',
    ['level_up'] = 'You earned %d XP! You are now Level %d %s (%d XP)',
    ['delivery_failed_money'] = 'You lost $%d for failing the delivery!',
    ['delivery_failed_xp'] = 'You lost %d XP for failing the delivery!',
    ['delivery_timeout'] = 'You Failed to deliver the pizza in time, giving you new delivery',
    
    -- Vehicle Selection
    ['selected_vehicle'] = 'Selected %s for delivery!',
    ['vehicle_locked_level'] = 'You need to reach level %d to unlock %s',
    ['vehicle_available'] = 'Available',
    ['vehicle_unlock_level'] = 'Unlock at Level %d',
    ['level_name'] = 'Level Name',
    ['available'] = 'Available',
    ['level_required'] = 'Level Required',
    
    -- Level Information
    ['current_level_info'] = 'Level: %d %s | XP: %d | Next Level: %d XP needed',
    ['level_description'] = 'Current Experience: %d XP',
    ['level_stats'] = 'Level %d %s - XP: %d - Next: %d XP needed',
    
    -- Debug Messages
    ['testing_store_pizzas'] = 'Testing store pizzas function...',
    ['delivery_debug_info'] = '=== Delivery Debug Info ===',
    ['debug_hired'] = 'Hired: %s',
    ['debug_has_pizza'] = 'Has Pizza: %s',
    ['debug_active_order'] = 'Active Order: %s',
    ['debug_pizza_delivered'] = 'Pizza Delivered: %s',
    ['debug_stored_pizzas'] = 'Stored Pizzas: %d',
    ['debug_delivery_location'] = 'Delivery Location: %.2f, %.2f, %.2f',
    ['debug_no_delivery_location'] = 'No delivery location set',
    ['pizza_kitchen_distance'] = 'Distance to pizza kitchen: %.2f meters',
    ['pizza_kitchen_location'] = 'Kitchen location: %.2f, %.2f, %.2f',
    ['pizza_location_disabled'] = 'Physical pizza making location is disabled in config',
    ['teleported_to_kitchen'] = 'Teleported to pizza kitchen!',
    ['pizza_marker_info'] = '=== Pizza Marker Info ===',
    ['marker_details'] = 'Type: %d | Size: %.1f,%.1f,%.1f',
    ['marker_color_details'] = 'Color: %d,%d,%d,%d | Bob: %s | Rotate: %s',
    ['marker_draw_distance'] = 'Draw Distance: %.1fm',
    ['marker_disabled'] = '3D Marker is disabled in config',
    
    -- Main Menu
    ['pizza_job_main_menu'] = 'Pizza Job',
    ['start_job_menu'] = 'Start Job',
    ['stop_job_menu'] = 'Stop Job',
    ['vehicle_garage'] = 'Vehicle Garage',
    ['check_stats'] = 'Check Stats',
    ['select_vehicle'] = 'Select Vehicle',
    ['back'] = 'Back',
    ['back_to_main_menu'] = 'Return to pizza job menu',
    
    -- Menu Descriptions
    ['start_job_desc'] = 'Begin working as a pizza delivery driver',
    ['stop_job_desc'] = 'End your current pizza delivery job',
    ['garage_desc'] = 'Select and spawn delivery vehicles',
    ['stats_desc'] = 'View your level, experience and progress',
    ['select_vehicle_desc'] = 'Choose your delivery vehicle',
    ['pizza_making_desc'] = 'Start making pizzas to earn XP and money',
    
    -- Vehicle Garage Menu
    ['garage_main_title'] = 'Pizza Delivery Garage',
    ['vehicle_selection'] = 'Vehicle Selection',
    ['spawn_vehicle'] = 'Spawn Vehicle',
    ['vehicle_info'] = 'Vehicle Information',
    ['required_level'] = 'Required Level',
    ['current_level'] = 'Current Level',
    ['status'] = 'Status',
    ['progress'] = 'Progress',
    
    -- Stats Menu
    ['stats_main_title'] = 'Pizza Job Statistics',
    ['your_level'] = 'Your Level',
    ['total_experience'] = 'Total Experience',
    ['experience_to_next'] = 'Experience to Next Level',
    ['experience_needed'] = '%d XP needed',
    ['current_vehicle'] = 'Current Vehicle',
    ['no_vehicle'] = 'No vehicle',
    ['max_level'] = 'Max Level',
    ['deliveries_completed'] = 'Deliveries Completed',
    ['total_earnings'] = 'Total Earnings',
    
    -- Pizza Making Menu
    ['making_pizzas_title'] = 'Making Pizzas...',
    ['stop_making_pizzas'] = 'Stop Making Pizzas',
    ['stop_making_pizzas_desc'] = 'Stop the pizza making process',
    
    -- UI Text
    ['pizza_job_garage'] = 'Pizza Job & Garage',
    ['delivery_vehicle'] = 'Delivery Vehicle',
    ['delivery_destination'] = 'Delivery Destination',
    ['pizza_oven'] = 'Pizza Oven',
    ['next_customer'] = 'Next Customer',
    ['delivery_timer'] = 'Delivery Timer',
    ['deliver_the_pizza'] = 'Deliver the pizza!',
    ['customer_details'] = 'Customer Details:',
    ['name'] = 'Name:',
    ['address'] = 'Address:',
    ['level'] = 'Level:',
    ['experience'] = 'Experience:',
    ['next_level_in'] = 'Next Level in:',
    
    -- System Messages
    ['ox_lib_not_available'] = 'ox_lib not available, storing 1 pizza',
    ['cannot_deliver_conditions'] = 'Cannot deliver pizza - conditions not met!',
    ['new_delivery_started'] = 'New delivery started!',
    ['delivery_zone_triggered'] = 'Delivery zone triggered!',
    ['store_pizzas_triggered'] = 'Store pizzas action triggered!',
    ['take_pizza_triggered'] = 'Take pizza action triggered!',
    ['return_pizza_triggered'] = 'Return pizza action triggered!',
    ['deliver_pizza_triggered'] = 'DeliverPizza event triggered!'
}

-- Hebrew Locale
Locales['he'] = {
    -- Job Actions
    ['start_job'] = 'התחל עבודת משלוח פיצה',
    ['stop_job'] = 'עצור עבודת משלוח פיצה',
    ['make_pizzas'] = 'הכן פיצות',
    ['deliver_pizza'] = 'מסור פיצה',
    ['store_pizzas'] = 'אחסן פיצות (%d מאוחסנות)',
    ['take_pizza'] = 'קח פיצה (%d זמינות)',
    ['return_pizza'] = 'החזר פיצה',
    
    -- Notifications - Job Status
    ['job_started'] = 'עבודת משלוח פיצה התחילה!',
    ['job_stopped'] = 'עבודת משלוח פיצה הופסקה!',
    ['not_working'] = 'אתה לא עובד כרגע!',
    ['new_delivery'] = 'יש לך משלוח חדש!',
    ['pizza_delivered'] = 'פיצה נמסרה. אנא המתן למשלוח הבא!',
    
    -- Notifications - Pizza Making
    ['pizza_made_success'] = 'פיצה הוכנה בהצלחה! +1 קופסת משלוח פיצה',
    ['pizza_making_started_kitchen'] = 'התחלת להכין פיצות! התרחק מהמטבח כדי להפסיק',
    ['pizza_making_started_menu'] = 'התחלת להכין פיצות! לחץ [ESC] או חזור לתפריט כדי להפסיק',
    ['pizza_making_stopped'] = 'הפסקת להכין פיצות',
    ['pizza_making_too_far'] = 'התרחקת יותר מדי מהמטבח! הכנת הפיצות הופסקה.',
    ['need_pizza_kitchen'] = 'אתה צריך להיות במטבח הפיצה כדי להכין פיצות!',
    
    -- Notifications - Vehicle & Delivery
    ['vehicle_spawned'] = 'רכב הוזמן והמטרה נוספה!',
    ['no_delivery_vehicle'] = 'לא נמצא רכב משלוחים!',
    ['need_pizza_first'] = 'אתה צריך לקחת פיצה מהרכב קודם!',
    ['pizza_already_delivered'] = 'הפיצה כבר נמסרה!',
    ['took_pizza_from_vehicle'] = 'לקחת פיצה מהרכב!',
    ['returned_pizza_to_vehicle'] = 'החזרת את הפיצה לרכב!',
    ['no_pizza_to_return'] = 'אין לך פיצה להחזיר!',
    ['need_closer_to_vehicle'] = 'אתה צריך להיות קרוב יותר לרכב!',
    ['no_pizzas_in_vehicle'] = 'אין פיצות מאוחסנות ברכב!',
    ['cannot_store_pizzas'] = 'לא ניתן לאחסן פיצות כרגע!',
    
    -- Notifications - Inventory & Items
    ['need_pizza_boxes_to_store'] = 'אתה צריך קופסאות משלוח פיצה כדי לאחסן!',
    ['no_pizza_boxes'] = 'אין לך קופסאות משלוח פיצה!',
    ['not_enough_pizza_boxes'] = 'אין לך מספיק קופסאות משלוח פיצה!',
    ['stored_pizzas_success'] = 'אוחסנו %d פיצות ברכב!',
    ['invalid_quantity'] = 'כמות לא תקינה!',
    ['no_quantity_selected'] = 'לא נבחרה כמות!',
    ['pizza_boxes_count'] = 'יש לך %d קופסאות משלוח פיצה',
    
    -- Notifications - Payment & XP
    ['no_deliveries_no_pay'] = 'לא השלמת אף משלוח, לכן לא שולמת.',
    ['must_return_vehicle'] = 'אתה חייב להחזיר את רכב העבודה כדי לקבל תשלום.',
    ['received_money'] = 'קיבלת $%d',
    ['received_delivery_payment'] = 'קיבלת $%d עבור המשלוח שלך!',
    ['pizza_made_xp'] = 'פיצה הוכנה! +%d נק״נ | רמה %d %s (%d נק״נ)',
    ['pizza_made_money'] = 'פיצה הוכנה! +$%d',
    ['level_up'] = 'הרווחת %d נק״נ! אתה עכשיו ברמה %d %s (%d נק״נ)',
    ['delivery_failed_money'] = 'איבדת $%d בגלל כישלון במשלוח!',
    ['delivery_failed_xp'] = 'איבדת %d נק״נ בגלל כישלון במשלוח!',
    ['delivery_timeout'] = 'נכשלת למסור את הפיצה בזמן, נותן לך משלוח חדש',
    
    -- Vehicle Selection
    ['selected_vehicle'] = 'נבחר %s למשלוח!',
    ['vehicle_locked_level'] = 'אתה צריך להגיע לרמה %d כדי לפתוח %s',
    ['vehicle_available'] = 'זמין',
    ['vehicle_unlock_level'] = 'פתח ברמה %d',
    ['level_name'] = 'שם הרמה',
    ['available'] = 'זמין',
    ['level_required'] = 'רמה נדרשת',
    
    -- Level Information
    ['current_level_info'] = 'רמה: %d %s | נק״נ: %d | רמה הבאה: %d נק״נ נדרש',
    ['level_description'] = 'ניסיון נוכחי: %d נק״נ',
    ['level_stats'] = 'רמה %d %s - נק״נ: %d - הבא: %d נק״נ נדרש',
    
    -- Debug Messages
    ['testing_store_pizzas'] = 'בודק פונקציית אחסון פיצות...',
    ['delivery_debug_info'] = '=== מידע ניפוי באגים למשלוח ===',
    ['debug_hired'] = 'נשכר: %s',
    ['debug_has_pizza'] = 'יש פיצה: %s',
    ['debug_active_order'] = 'הזמנה פעילה: %s',
    ['debug_pizza_delivered'] = 'פיצה נמסרה: %s',
    ['debug_stored_pizzas'] = 'פיצות מאוחסנות: %d',
    ['debug_delivery_location'] = 'מיקום משלוח: %.2f, %.2f, %.2f',
    ['debug_no_delivery_location'] = 'לא הוגדר מיקום משלוח',
    ['pizza_kitchen_distance'] = 'מרחק למטבח הפיצה: %.2f מטרים',
    ['pizza_kitchen_location'] = 'מיקום המטבח: %.2f, %.2f, %.2f',
    ['pizza_location_disabled'] = 'מיקום הכנת הפיצה הפיזי מושבת בהגדרות',
    ['teleported_to_kitchen'] = 'הועברת למטבח הפיצה!',
    ['pizza_marker_info'] = '=== מידע על סמן הפיצה ===',
    ['marker_details'] = 'סוג: %d | גודל: %.1f,%.1f,%.1f',
    ['marker_color_details'] = 'צבע: %d,%d,%d,%d | זז: %s | מסתובב: %s',
    ['marker_draw_distance'] = 'מרחק ציור: %.1fמ״',
    ['marker_disabled'] = 'סמן תלת מימדי מושבת בהגדרות',
    
    -- Main Menu
    ['pizza_job_main_menu'] = 'עבודת פיצה',
    ['start_job_menu'] = 'התחל עבודה',
    ['stop_job_menu'] = 'עצור עבודה',
    ['vehicle_garage'] = 'חניון רכבים',
    ['check_stats'] = 'בדוק סטטיסטיקות',
    ['select_vehicle'] = 'בחר רכב',
    ['back'] = 'חזור',
    ['back_to_main_menu'] = 'חזור לתפריט עבודת הפיצה',
    
    -- Menu Descriptions
    ['start_job_desc'] = 'התחל לעבוד כנהג משלוחי פיצה',
    ['stop_job_desc'] = 'סיים את עבודת משלוח הפיצה הנוכחית',
    ['garage_desc'] = 'בחר והזמן רכבי משלוח',
    ['stats_desc'] = 'צפה ברמה, ניסיון והתקדמות שלך',
    ['select_vehicle_desc'] = 'בחר את רכב המשלוח שלך',
    ['pizza_making_desc'] = 'התחל להכין פיצות כדי להרוויח נק״נ וכסף',
    
    -- Vehicle Garage Menu
    ['garage_main_title'] = 'חניון משלוחי פיצה',
    ['vehicle_selection'] = 'בחירת רכב',
    ['spawn_vehicle'] = 'הזמן רכב',
    ['vehicle_info'] = 'מידע על הרכב',
    ['required_level'] = 'רמה נדרשת',
    ['current_level'] = 'רמה נוכחית',
    ['status'] = 'סטטוס',
    ['progress'] = 'התקדמות',
    
    -- Stats Menu
    ['stats_main_title'] = 'סטטיסטיקות עבודת פיצה',
    ['your_level'] = 'הרמה שלך',
    ['total_experience'] = 'ניסיון כולל',
    ['experience_to_next'] = 'ניסיון לרמה הבאה',
    ['experience_needed'] = '%d נק״נ נדרש',
    ['current_vehicle'] = 'רכב נוכחי',
    ['no_vehicle'] = 'אין רכב',
    ['max_level'] = 'רמה מקסימלית',
    ['deliveries_completed'] = 'משלוחים שהושלמו',
    ['total_earnings'] = 'סך הכנסות',
    
    -- Pizza Making Menu
    ['making_pizzas_title'] = 'מכין פיצות...',
    ['stop_making_pizzas'] = 'הפסק להכין פיצות',
    ['stop_making_pizzas_desc'] = 'הפסק את תהליך הכנת הפיצות',
    
    -- UI Text
    ['pizza_job_garage'] = 'עבודת פיצה וחניון',
    ['delivery_vehicle'] = 'רכב משלוחים',
    ['delivery_destination'] = 'יעד משלוח',
    ['pizza_oven'] = 'תנור פיצה',
    ['next_customer'] = 'לקוח הבא',
    ['delivery_timer'] = 'טיימר משלוח',
    ['deliver_the_pizza'] = 'מסור את הפיצה!',
    ['customer_details'] = 'פרטי לקוח:',
    ['name'] = 'שם:',
    ['address'] = 'כתובת:',
    ['level'] = 'רמה:',
    ['experience'] = 'ניסיון:',
    ['next_level_in'] = 'רמה הבאה בעוד:',
    
    -- System Messages
    ['ox_lib_not_available'] = 'ox_lib לא זמין, מאחסן 1 פיצה',
    ['cannot_deliver_conditions'] = 'לא ניתן למסור פיצה - התנאים לא מתקיימים!',
    ['new_delivery_started'] = 'משלוח חדש התחיל!',
    ['delivery_zone_triggered'] = 'אזור המשלוח הופעל!',
    ['store_pizzas_triggered'] = 'פעולת אחסון פיצות הופעלה!',
    ['take_pizza_triggered'] = 'פעולת לקיחת פיצה הופעלה!',
    ['return_pizza_triggered'] = 'פעולת החזרת פיצה הופעלה!',
    ['deliver_pizza_triggered'] = 'אירוע מסירת פיצה הופעל!'
}

/**
 * Get localized text based on current locale
 * @param key string - The translation key
 * @param ... - Optional parameters for string formatting
 * @return string - Localized text
 */
function _L(key, ...)
    local currentLocale = Config.Locale or 'en'
    local localeData = Locales[currentLocale]
    
    if not localeData then
        print(('Locale %s not found, falling back to English'):format(currentLocale))
        localeData = Locales['en']
    end
    
    local text = localeData[key]
    if not text then
        print(('Translation key "%s" not found for locale %s'):format(key, currentLocale))
        -- Fallback to English if key not found
        text = Locales['en'][key] or ('Missing translation: %s'):format(key)
    end
    
    -- Handle string formatting if additional arguments provided
    if ... then
        return string.format(text, ...)
    end
    
    return text
end

/**
 * Export function for external access
 */
GetLocalizedText = _L 