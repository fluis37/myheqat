extend view entity Z04_C_TRAVELITEM with {
    @Consumption.valueHelpDefinition: [
    { entity: { name: '/LRN/437_I_ClassStdVH',
                element: 'ClassID' } }]
    Item.ZZClassZ04
}
