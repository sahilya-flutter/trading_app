import '../../../core/constants/app_constants.dart';

class WalletModel {
  final int balancePaise;

  const WalletModel({
    required this.balancePaise,
  });

  factory WalletModel.initial() => const WalletModel(
        balancePaise: AppConstants.initialWalletBalancePaise,
      );

  WalletModel copyWith({int? balancePaise}) {
    return WalletModel(
      balancePaise: balancePaise ?? this.balancePaise,
    );
  }

  Map<String, dynamic> toJson() => {
        'balancePaise': balancePaise,
      };

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        balancePaise: (json['balancePaise'] as num?)?.toInt() ??
            AppConstants.initialWalletBalancePaise,
      );
}
