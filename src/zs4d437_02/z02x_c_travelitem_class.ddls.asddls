extend view entity Z02_C_TravelItem with {
    @Consumption.valueHelpDefinition: [ { 
        entity: { 
            name: '/LRN/437_I_ClassStdVH', 
            element: 'ClassID' 
        } 
    } ]
    Item.ZZClassZ02
}
