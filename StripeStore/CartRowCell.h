//
//  CartRowCell.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-09.
//

#import <UIKit/UIKit.h>
#import "CartLineItem.h"

@interface CartRowCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UIStepper *quantityStepper;
@property (weak, nonatomic) IBOutlet UILabel *rowTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (strong, nonatomic) CartLineItem *lineItem;
@end
