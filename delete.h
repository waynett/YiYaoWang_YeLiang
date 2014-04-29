设置背景色
//    [self.view setBackgroundColor:[UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0]];

logo栏  yl-取消导航栏
//    UIImageView *titleView=[[UIImageView alloc]initWithFrame:CGRectMake(0,yValue,320,44)];
//    [titleView setImage:[UIImage imageNamed:@"title_bg.png"]];
//    [self.view addSubview:titleView];
//    [titleView release];
//    yValue+=44.0;

logo栏-选择省份按钮  yl-取消首页省份选择
//	UIButton *selectedProvince=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 61, 44)];
//    [selectedProvince setTag:VIEW_TAG_SEL_PROVINCE_BUTTON];
//    [selectedProvince setTitleEdgeInsets:UIEdgeInsetsMake(0, 11, 0, 0)];
//
//	if(m_CurrentProvinceStr==nil || [m_CurrentProvinceStr isEqualToString:@""])
//    {
//        //如果未切换过省份
//		[selectedProvince setTitle:@"上海" forState:UIControlStateNormal];
//		self.m_CurrentProvinceStr=[[[NSString alloc] initWithString:@"上海"] autorelease];
//	}
//    else
//    {
//		[selectedProvince setTitle:m_CurrentProvinceStr forState:0];
//	}
//    [selectedProvince setBackgroundImage:[UIImage imageNamed:@"title_GPS_btn.png"] forState:UIControlStateNormal];
//    [selectedProvince setBackgroundImage:[UIImage imageNamed:@"title_GPS_btn_sel.png"] forState:UIControlStateHighlighted];
//	selectedProvince.titleLabel.font=[UIFont boldSystemFontOfSize:13.0];
//    [selectedProvince.titleLabel setTextAlignment:NSTextAlignmentLeft];
//	selectedProvince.titleLabel.shadowColor = [UIColor darkGrayColor];
//	selectedProvince.titleLabel.shadowOffset = CGSizeMake(1.0, -1.0);
//	[selectedProvince setTitleColor:[UIColor whiteColor] forState:0];
//	[selectedProvince addTarget:self action:@selector(enterSwitchProvince) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:selectedProvince];
//    [selectedProvince release];

设置searchBar_bg
//        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
//        [imageView setImage:[UIImage imageNamed:@"searchBar_bg.png"]];
//        [self addSubview:imageView];
//        [imageView release];