/**
 * Handler class to handle all logic for Revenue Data trigger
 *
 * @author Aditi Satpute
 */
public with sharing class RevenueDataTH {

    /**
     * Main trigger handling logic to be called from Revenue Data trigger
     */
    public static void triggerHandler(
            Boolean isBefore,
            Boolean isAfter,
            Boolean isInsert,
            Boolean isUpdate,
            Boolean isDelete,
            List<RevenueData__c> newRecords,
            Map<Id, RevenueData__c> oldRecordsMap
    ) {
        if (isBefore) {
            beforeHandler(isInsert, isUpdate, isDelete, newRecords, oldRecordsMap);
        }
    }

    /**
     * Before trigger handler to redirect properly based on insert, update or delete
     */
    private static void beforeHandler(
            Boolean isInsert,
            Boolean isUpdate,
            Boolean isDelete,
            List<RevenueData__c> newRecords,
            Map<Id, RevenueData__c> oldRecordsMap
    ) {
        if (isInsert) {
            beforeInsert(newRecords);
        }
    }

    /**
     * Before insert logic
     */
    private static void beforeInsert(List<RevenueData__c> newRecords) {
        setAlignmentForRevenueData(newRecords);
    }

    /**
     * Method to set all alignment for Revenue Data
     *   - Set Channel alignment
     *   - Set MarketerStatistics alignment
     *   - Set Channel Data alignment
     * @param newRevenueDataList List of Revenue data that needs to be inserted
     */
    private static void setAlignmentForRevenueData(List<RevenueData__c> newRevenueDataList) {

      /*  List<String> splitDateDetails = new List<String>();

        // Fetch all the details of Channels
        List<Channel__c> channelList = [
            SELECT
                Id,
                Name,
                ExtId__c,
                Platform__c
            FROM
                Channel__c
        ];

        // Fetch details of Marketer Statistics
        List<MarketerStatistics__c> marketerStatisticsList = [
            SELECT
                Id,
                Name,
                Channel_Ref__c,
                Channel_Ref__r.ExtId__c,
                Marketer__c,
                Month__c,
                Year__c
            FROM
                MarketerStatistics__c
        ];

        // Fetch details of Currency Table
        List<CurrencyTable__c> currencyTableList = [
            SELECT
                Id,
                Name,
                Conversion_Rate__c,
                Currency_Code__c,
                ValidDate__c
            FROM
                CurrencyTable__c
            ORDER BY
                ValidDate__c DESC
        ];

        // Prepare a Map with External Id of Channel as its Key along with its instance
        Map<String, Channel__c> mapChannelExtIdToInstance = new Map<String, Channel__c>();
        for (Channel__c channelInstance : channelList) {
            mapChannelExtIdToInstance.put(channelInstance.ExtId__c, channelInstance);
        }
        System.debug('--mapChannelExtIdToInstance--->' + mapChannelExtIdToInstance);

        // Prepare a Map with External Id of Marketer statistics channel as its Key along with its instance
        Map<String, MarketerStatistics__c> mapMarketerStatisticsChannelExtIdToInstance =
            new Map<String, MarketerStatistics__c>();
        Map<String, MarketerStatistics__c> mapMarketerStatisticsChannelExtIdToInstanceToInsert =
            new Map<String, MarketerStatistics__c>();

        for (MarketerStatistics__c marketerStatisticsInstance : marketerStatisticsList) {
            mapMarketerStatisticsChannelExtIdToInstance.put(
                marketerStatisticsInstance.Channel_Ref__r.ExtId__c,
                marketerStatisticsInstance
            );
        }
        System.debug('--mapMarketerStatisticsChannelExtIdToInstance--->'
            + mapMarketerStatisticsChannelExtIdToInstance
        );

        // Prepare a Map with Currency code as its key along with Value as List of instances
        // sorted in descending order with respect to Valid Date
        Map<string, List<CurrencyTable__c>> mapCurrencyCodeToCurrencyList =
            new Map<string, List<CurrencyTable__c>>();
        for (CurrencyTable__c currencyTableInstance : currencyTableList) {
            if (mapCurrencyCodeToCurrencyList.containsKey(currencyTableInstance.Currency_Code__c)) {
                List<CurrencyTable__c> existingCurrencyTableList =
                    mapCurrencyCodeToCurrencyList.get(currencyTableInstance.Currency_Code__c);
                existingCurrencyTableList.add(currencyTableInstance);
                mapCurrencyCodeToCurrencyList.put(
                    currencyTableInstance.Currency_Code__c,
                    existingCurrencyTableList
                );
            } else {
                mapCurrencyCodeToCurrencyList.put(
                    currencyTableInstance.Currency_Code__c,
                    new List<CurrencyTable__c> {currencyTableInstance}
                );
            }
        }
        System.debug('--mapCurrencyCodeToCurrencyList--->' + mapCurrencyCodeToCurrencyList);

        // Iterate over the Revenue Data List that is being inserted
        for (RevenueData__c revenuedataInstance : newRevenueDataList) {

            // Verify the channel is present for the revenue data
            if (mapChannelExtIdToInstance.containsKey(revenuedataInstance.channelExtId__c)) {
                Channel__c channelInstance =
                    mapChannelExtIdToInstance.get(revenuedataInstance.channelExtId__c);

                if (revenuedataInstance.validDate__c != null) {
                    splitDateDetails =
                        String.valueOf(revenuedataInstance.validDate__c).split('-');
                    System.debug('---splitDateDetails--->'+splitDateDetails);
                }

                // Verify the Marketer Statistics record for the linked channel is
                // present for the revenue data
                if (mapMarketerStatisticsChannelExtIdToInstance.containsKey(
                        revenuedataInstance.channelExtId__c
                )) {
                    MarketerStatistics__c marketerStatisticsInstance =
                        mapMarketerStatisticsChannelExtIdToInstance.get(
                            revenuedataInstance.channelExtId__c
                        );
                    System.debug('--->In if');

                    // Verify that the Marketer statistics have same Marketer as the Revenue Data
                    if (revenuedataInstance.Marketer__c == marketerStatisticsInstance.Marketer__c) {

                        // Find the Marketer Statistic record based on Month and Year
                        // and align it to revenue data
                        if (
                                splitDateDetails.size() == 3
                                && marketerStatisticsInstance.Month__c == splitDateDetails[1].trim()
                                && marketerStatisticsInstance.Year__c == splitDateDetails[0].trim()
                        ) {
                            revenuedataInstance.MarketerStatistics_Ref__c =
                                marketerStatisticsInstance.Id;
                        } else {
                            revenuedataInstance.addError(
                                'No Marketer Statistics record present for Month "'
                                    + splitDateDetails[1].trim() + '" and Year "'
                                    + splitDateDetails[0].trim() + '"'
                            );
                        }
                    } else {
                        System.debug('--->In else');
                        revenuedataInstance.addError(
                            'No Marketer Statistics record present for Marketer "'
                                + revenuedataInstance.Marketer__c + '"'
                        );
                    }
                } else {

                    // If Marketer Statistics record not found for the specified Channel
                    // External Id then create new Marketer Statistics record
                    MarketerStatistics__c marketerStatisticsInstance = new MarketerStatistics__c();
                    if (splitDateDetails.size() == 3) {
                        marketerStatisticsInstance.Month__c = splitDateDetails[1].trim();
                        marketerStatisticsInstance.Year__c = splitDateDetails[0].trim();
                        marketerStatisticsInstance.Marketer__c = revenuedataInstance.Marketer__c;
                        marketerStatisticsInstance.Channel_Ref__c = channelInstance.Id;
                        mapMarketerStatisticsChannelExtIdToInstanceToInsert.put(
                            channelInstance.ExtId__c,
                            marketerStatisticsInstance
                        );
                    }
                }
            }

            // Set the Currency Table linking for respective revenue data
            if (mapCurrencyCodeToCurrencyList.containsKey(revenuedataInstance.Currency__c)) {
                List<CurrencyTable__c> currencyTableListDetails =
                    mapCurrencyCodeToCurrencyList.get(revenuedataInstance.Currency__c);
                for (CurrencyTable__c currencyTableInstance :
                        mapCurrencyCodeToCurrencyList.get(revenuedataInstance.Currency__c)
                ) {
                    if (currencyTableInstance.validDate__c == revenuedataInstance.validDate__c) {
                        revenuedataInstance.ConversionRate_Ref__c = currencyTableInstance.Id;
                    }
                }

                // If no valid Data found related to Currency Table then link with the newest Record
                if (
                        revenuedataInstance.ConversionRate_Ref__c == null
                        && currencyTableListDetails.size() > 0
                ) {
                    revenuedataInstance.ConversionRate_Ref__c =
                        currencyTableListDetails[currencyTableListDetails.size() - 1].Id;
                }
            }
        }

        System.debug('--mapMarketerStatisticsChannelExtIdToInstanceToInsert--->'
            + mapMarketerStatisticsChannelExtIdToInstanceToInsert
        );
        // Insert the Marketer Statistics records whose channels are present for the revenue data
        if (mapMarketerStatisticsChannelExtIdToInstanceToInsert.size() > 0) {
            Database.SaveResult[] saveResultList =
                Database.insert(
                    mapMarketerStatisticsChannelExtIdToInstanceToInsert.values(),
                    false
                );

            // Iterate over the revenue data to align proper linking between newly inserted
            // Marketer Statistics to revenue data
            for (RevenueData__c revenuedataInstance : newRevenueDataList) {
                if (mapMarketerStatisticsChannelExtIdToInstanceToInsert.containsKey(
                        revenuedataInstance.channelExtId__c
                )) {
                        MarketerStatistics__c marketerStatisticsInstance =
                            mapMarketerStatisticsChannelExtIdToInstanceToInsert.get(
                                revenuedataInstance.channelExtId__c
                            );
                        if (marketerStatisticsInstance != null) {
                            revenuedataInstance.MarketerStatistics_Ref__c =
                                marketerStatisticsInstance.Id;
                        }
                }
            }
        }
        System.debug('--newRevenueDataList--->' + newRevenueDataList);*/
    }
}