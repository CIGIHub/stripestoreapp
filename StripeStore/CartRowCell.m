//
//  CartRowCell.m
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-09.
//

#import "CartRowCell.h"
#import "Order.h"

@implementation CartRowCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)stepperValueChanged:(id)sender
{
    double stepperValue = self.quantityStepper.value;
    
    NSDecimalNumber *orderTotal = [self.lineItem.order.orderTotal copy];
    orderTotal = [orderTotal decimalNumberBySubtracting:self.lineItem.rowTotal];
    
    self.lineItem.quantity = [NSNumber numberWithDouble:stepperValue];
    self.lineItem.rowTotal = [self.lineItem.itemPrice decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithMantissa:self.lineItem.quantity.longLongValue exponent:0 isNegative:NO]];
    
    orderTotal = [orderTotal decimalNumberByAdding:self.lineItem.rowTotal];
    self.lineItem.order.orderTotal = orderTotal;
    
    NSError *error = nil;
    if (![self.lineItem.managedObjectContext save:&error]){
        // Replace this implementation with code to handle
        // the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    if ([self.lineItem.quantity isEqualToNumber:[NSNumber numberWithInt:0]]){
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        NSDictionary *userInfo = @{ @"LineItem":self.lineItem };
        [nc postNotificationName:kCartDidZeroProduct  object:nil userInfo:userInfo];
    }

    
}

-(void)setLineItem:(CartLineItem *)lineItem
{
    _lineItem = lineItem;
    
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    self.rowTotalLabel.text = [formatter stringFromNumber: lineItem.rowTotal];
    self.productNameLabel.text = lineItem.itemName;
    self.quantityLabel.text = lineItem.quantity.stringValue;
    self.quantityStepper.value = lineItem.quantity.doubleValue;
    
}

@end
