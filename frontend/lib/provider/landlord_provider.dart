import 'package:flutter_riverpod/legacy.dart';
import 'landlord_state.dart';

class LandlordNotifier extends StateNotifier<LandlordState> {
  LandlordNotifier() : super(const LandlordState()) {
    _loadInitialData();
  }

  void _loadInitialData() {
    final defaultProperties = [
      const Property(
        id: 'prop1',
        name: 'Sunset Apartments',
        address: 'Sunset Heights, Unit 402',
        occupancyRate: 0.92,
        imageUrl:
            'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&q=80',
        totalUnits: 24,
        occupiedUnits: 22,
        vacantUnits: 2,
        monthlyRent: 14200.0,
      ),
      const Property(
        id: 'prop2',
        name: 'Maple Residency',
        address: '12 Valley Rd, Suite A',
        occupancyRate: 1.0,
        imageUrl:
            'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&q=80',
        totalUnits: 10,
        occupiedUnits: 10,
        vacantUnits: 0,
        monthlyRent: 18500.0,
      ),
    ];

    final defaultUnits = [
      const Unit(
        id: 'u101',
        name: 'Unit 101',
        status: 'Occupied',
        tenantName: 'John Smith',
        rent: 1200.0,
        amenities: ['Luxury Pool', '24/7 Gym', 'Maintenance'],
      ),
      const Unit(
        id: 'u102',
        name: 'Unit 102',
        status: 'Vacant',
        tenantName: '',
        rent: 1100.0,
        amenities: ['Luxury Pool', 'Maintenance'],
      ),
      const Unit(
        id: 'u103',
        name: 'Unit 103',
        status: 'Maintenance',
        tenantName: '',
        rent: 1050.0,
        amenities: ['Luxury Pool', '24/7 Gym', 'Maintenance'],
      ),
    ];

    final defaultTenants = [
      const Tenant(
        id: 't1',
        name: 'John Smith',
        unitName: 'Sunset Heights Apts, Unit 402',
        contact: '(555) 123-4567',
        email: 'john.smith@example.com',
        emergencyContactName: 'Jane Smith (Mother)',
        emergencyContactPhone: '(555) 987-6543',
        memos: [
          'Tenant reported kitchen sink leak.',
          'Lease renewal pending for June.',
        ],
        balance: 0.0,
        status: 'Active',
        dateJoined: 'Dec 12, 2023',
      ),
      const Tenant(
        id: 't2',
        name: 'Sarah Jenkins',
        unitName: 'Maple Residency, Unit 4',
        contact: '(555) 765-4321',
        email: 'sarah.j@example.com',
        emergencyContactName: 'David Jenkins (Father)',
        emergencyContactPhone: '(555) 111-2222',
        memos: ['Late fee applied for May.', 'Requested AC repair last week.'],
        balance: 450.0,
        status: 'Late Payment',
        dateJoined: 'Aug 15, 2024',
      ),
    ];

    final defaultWorkOrders = [
      const WorkOrder(
        id: '105',
        title: 'Kitchen Sink Leak',
        description:
            'Tenant reported a leak under the kitchen sink. Water is pooling inside the cabinet and needs inspection and repair.',
        propertyName: 'Sunset Heights Apts',
        unitName: 'Unit 402',
        tenantName: 'John Smith',
        priority: 'High',
        status: 'In-Progress',
        photos: [
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&q=80',
        ],
        category: 'Plumbing',
        date: 'May 19, 2026',
        timeSlot: '2:00 PM - 4:00 PM',
        accessInstructions:
            'Tenant is available after 1 PM. Vendor should call before arrival.',
        vendorName: 'Mike Plumbing',
        vendorPhone: '(555) 234-5678',
        bidAmount: 350.0,
      ),
      const WorkOrder(
        id: '101',
        title: 'AC Not Working',
        description:
            'AC unit is blowing warm air in the living room. Requires urgent compressor check.',
        propertyName: 'Sunset Heights Apts',
        unitName: 'Unit 102',
        tenantName: 'John Smith',
        priority: 'Emergency',
        status: 'Request',
        photos: [],
        category: 'HVAC',
        date: 'May 20, 2026',
        timeSlot: '10:00 AM - 12:00 PM',
        accessInstructions: 'Tenant is not home. Use Master Key to enter.',
      ),
      const WorkOrder(
        id: '108',
        title: 'Light Fixture Replacement',
        description:
            'Living room main ceiling light fixture needs replacement.',
        propertyName: 'Maple Residency',
        unitName: 'Unit 4',
        tenantName: 'Sarah Jenkins',
        priority: 'Low',
        status: 'Completed',
        photos: [],
        category: 'Electrical',
        date: 'May 15, 2026',
        timeSlot: '9:00 AM - 11:00 AM',
        accessInstructions: 'Tenant will open the door.',
        vendorName: 'Elite Home Repairs',
        vendorPhone: '(555) 876-5432',
        bidAmount: 120.0,
      ),
    ];

    final defaultBids = [
      const Bid(
        id: 'b1',
        vendorName: 'Mike Plumbing',
        rating: 4.8,
        totalJobs: 124,
        price: 350.0,
        time: 'Today, 2:00 PM',
        avatarUrl:
            'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=100&q=80',
      ),
      const Bid(
        id: 'b2',
        vendorName: 'QuickFix Maintenance',
        rating: 4.6,
        totalJobs: 89,
        price: 300.0,
        time: 'Tomorrow, 11:30 AM',
        avatarUrl:
            'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=100&q=80',
      ),
      const Bid(
        id: 'b3',
        vendorName: 'Elite Home Repairs',
        rating: 4.9,
        totalJobs: 210,
        price: 450.0,
        time: 'Today, 5:00 PM',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80',
      ),
    ];

    final defaultChatMessages = [
      const ChatMessage(
        id: 'c1',
        senderName: 'Mike Plumbing',
        role: 'Vendor',
        message:
            'I can visit at 2:00 PM today. I have the standard sink gaskets in stock.',
        time: '10:00 AM',
      ),
      const ChatMessage(
        id: 'c2',
        senderName: 'Landlord',
        role: 'Landlord',
        message:
            'Sounds good. Tenant will be home at that time. Please ring unit 402.',
        time: '10:15 AM',
      ),
      const ChatMessage(
        id: 'c3',
        senderName: 'John Smith',
        role: 'Tenant',
        message:
            'Perfect, I will unlock the side gate as well for easy access.',
        time: '10:30 AM',
      ),
    ];

    state = LandlordState(
      properties: defaultProperties,
      units: defaultUnits,
      tenants: defaultTenants,
      workOrders: defaultWorkOrders,
      bids: defaultBids,
      chatMessages: defaultChatMessages,
      totalCollected: 24500.0,
      totalOutstanding: 3200.0,
      occupancyRate: 0.94,
    );
  }

  // Add unit
  void addUnit(Unit unit) {
    state = state.copyWith(units: [...state.units, unit]);
  }

  // Add Tenant Memo
  void addMemoToTenant(String tenantId, String memo) {
    final updatedTenants = state.tenants.map((t) {
      if (t.id == tenantId) {
        return t.copyWith(memos: [...t.memos, memo]);
      }
      return t;
    }).toList();
    state = state.copyWith(tenants: updatedTenants);
  }

  // Create Work Order
  void createWorkOrder(WorkOrder order) {
    state = state.copyWith(workOrders: [order, ...state.workOrders]);
  }

  // Assign Bid
  void assignBidToWorkOrder(String orderId, Bid bid) {
    final updatedOrders = state.workOrders.map((wo) {
      if (wo.id == orderId) {
        return wo.copyWith(
          status: 'Assigned',
          vendorName: bid.vendorName,
          bidAmount: bid.price,
          timeSlot: bid.time,
        );
      }
      return wo;
    }).toList();
    state = state.copyWith(workOrders: updatedOrders);
  }

  // Chat message sending
  void sendMessage(String text) {
    final newMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderName: 'Landlord',
      role: 'Landlord',
      message: text,
      time: 'Just now',
    );
    state = state.copyWith(chatMessages: [...state.chatMessages, newMsg]);
  }

  // Update Work Order Status
  void updateWorkOrderStatus(String orderId, String newStatus) {
    final updatedOrders = state.workOrders.map((wo) {
      if (wo.id == orderId) {
        return wo.copyWith(status: newStatus);
      }
      return wo;
    }).toList();
    state = state.copyWith(workOrders: updatedOrders);
  }
}

final landlordProvider = StateNotifierProvider<LandlordNotifier, LandlordState>(
  (ref) => LandlordNotifier(),
);
