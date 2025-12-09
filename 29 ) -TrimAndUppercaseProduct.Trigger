trigger ProductTrigger on Product2 (before update) {

    /*
     * Question:
     * On update of Product2, trim leading/trailing spaces from Name and ProductCode.
     * Also ensure ProductCode is always stored in uppercase.
     */

    for (Product2 p : Trigger.New) {

        if (p.Name != null) {
            p.Name = p.Name.trim();
        }

        if (p.ProductCode != null) {
            p.ProductCode = p.ProductCode.trim().toUpperCase();
        }
    }
}
/*
On update of Product, trim spaces from Name & ProductCode, and convert ProductCode to uppercase.
*/
