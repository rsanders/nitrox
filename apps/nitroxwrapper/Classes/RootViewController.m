//
//  RootViewController.m
//  nitroxy1
//
//  Created by Robert Sanders on 9/26/08.
//  Copyright ViTrue, Inc. 2008. All rights reserved.
//

#import "RootViewController.h"
#import "nitroxdemoAppDelegate.h"

#import "NitroxWebViewController.h"

#import "WebViewInstance.h"

@implementation RootViewController


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [cells count];
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // static NSString *CellIdentifier = @"Cell";
    NSString *CellIdentifier = [[cells objectAtIndex:indexPath.row] name];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSLog(@"initializing cell for %@", CellIdentifier);
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // Get the object to display and set the value in the cell
    // NSDictionary *itemAtIndex = (NSDictionary *)[dataController objectInListAtIndex:indexPath.row];
    //cell.text = [itemAtIndex objectForKey:@"title"];

    cell.text = CellIdentifier;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic -- create and push a new view controller
    NSLog(@"selected row at %@", indexPath);

    /*
     Create the detail view controller and set its inspected item to the currently-selected item
     */
    
    id wvi = [cells objectAtIndex:[indexPath row]];
    if (!wvi) {
        NSLog(@"couldn't get item at %d", [indexPath row]);
        return;
    }
    
    UIViewController* vc = [wvi controller];
    if (vc) {
        [[self navigationController] pushViewController:vc animated:YES];
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind 
                                                      target:wvi action:@selector(goHome)];
        UINavigationItem* item = [[self navigationController] navigationItem];
        [item setRightBarButtonItem:button animated:YES];
    } else {
        NSLog(@"couldn't get view controller");
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to add the Edit button to the navigation bar.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    cells = [[NSMutableArray alloc] initWithCapacity:4];

    [cells addObject:[WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://localhost/nitrox.html"]
                                              baseURL:Nil
                                                 name:@"Local Main demo"]];

    [cells addObject:
        [WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://robertsanders.name/dev/nitrox/demos.html"]
                                 baseURL:Nil
                                    name:@"Remote Demos menu"]];

    [cells addObject:
     [WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://robertsanders.name/dev/nitrox/demos/photo.html"]
                              baseURL:Nil
                                 name:@"Remote Photo demo"]];
    [cells addObject:
     [WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://robertsanders.name/dev/nitrox/demos/main.html"]
                              baseURL:Nil
                                 name:@"Remote Main demo"]];
    
    [cells addObject:
     [WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://nitrox.devlab.vitrue.com/index.html"]
                              baseURL:Nil
                                 name:@"Devlab Index"]];    
    
/*    
    
    WebViewInstance *remote = [WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://robertsanders.name/dev/nitrox/nitrox.html"]
                                                       baseURL:[NSURL URLWithString:@"http://robertsanders.name/dev/nitrox/nitrox.html"]
                                                          name:@"direct remote load"];
    [remote setNoBase:YES];
    [cells addObject:remote];

    remote = [WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://robertsanders.name/dev/nitrox/nitrox.html"]
                                                       baseURL:[NSURL URLWithString:@"http://localhost/"]
                                                          name:@"d-remote localbase"];
    [remote setNoBase:YES];
    [cells addObject:remote];
    
    remote = [WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://robertsanders.name/dev/nitrox/nitrox.html"]
                                                       baseURL:[NSURL URLWithString:@"http://robertsanders.name/dev/nitrox/nitrox.html"]
                                                          name:@"INdirect remote w/rbase"];
    [cells addObject:remote];    

    remote = [WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://robertsanders.name/dev/nitrox/nitrox.html"]
                                                       baseURL:Nil
                                                          name:@"INdirect remote w/Nilbase"];
    [cells addObject:remote];    

    remote = [WebViewInstance instanceWithURL:
                      [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nitrox" ofType:@"html" inDirectory:@"web"]] 
                                              baseURL:Nil
                                         name:@"Direct File://Nitrox w/nil"];
    [remote setNoBase:YES];
    [cells addObject:remote];
    
    [cells addObject:[WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://localhost/demos/accel.html"]
                                              baseURL:Nil
                                                 name:@"Accel demo"]];

    [cells addObject:[WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://localhost/demos/location.html"]
                                              baseURL:Nil
                                                 name:@"Location demo"]];

    [cells addObject:[WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://localhost/demos/photo.html"]
                                              baseURL:Nil
                                                 name:@"Photo demo"]];    
    
    [cells addObject:[WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://robertsanders.name/dev/nitrox/nitroxy1.html"]
                                                                   baseURL:Nil 
                                                                      name:@"Pure Remote"]];

    [cells addObject:[WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://robertsanders.name/dev/nitrox/nitroxy1.html"]
                                             baseURL:[NSURL URLWithString:@"http://localhost:61607/"]
                                                name:@"Remote w/local base"]];

    [cells addObject:[WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://localhost:61607/index.html"]
                                                baseURL:Nil
                                                name:@"Local index w/nil"]];
    
    [cells addObject:[WebViewInstance instanceWithURL:[NSURL URLWithString:@"http://localhost:61607/index.html"]
                                              baseURL:[NSURL URLWithString:@"http://localhost:61607/"]
                                                name:@"Local index w/local base"]];
    */

    [self setTitle:@"Menu"];
}



/*
// Override to support editing the list
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support conditional editing of the list
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support rearranging the list
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the list
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end

