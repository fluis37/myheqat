extend view entity Z00_C_TravelItem with {
    @Consumption: {
        valueHelpDefinition: [{
            entity: {
                name: '/LRN/437_I_ClassStdVH',
                element: 'ClassID'
            }
        }]
    }
    Item.ZZClassZ00
}
