extend view entity Z05_C_TRAVELITEM with
{
  @Consumption.valueHelpDefinition: [
  { entity: { name: '/LRN/437_I_ClassStdVH',
              element: 'ClassID' } }]
  Item.ZZClassZ05
}
