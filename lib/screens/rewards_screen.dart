import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_data.dart';
import '../models/reward.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, _) {
      final p = context.palette;
      final balance = appState.coinBalance;
      final sortedRedemptions = appState.redemptions.reversed.toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rewards', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Spend the Fit Coins you earn from walking. 1 Fit Coin = 1,000 steps logged.',
                style: TextStyle(color: p.textMuted)),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [p.accent.withValues(alpha: 0.18), p.primary.withValues(alpha: 0.14)],
                ),
                border: Border.all(color: p.accent.withValues(alpha: 0.35)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('Your balance', style: TextStyle(color: p.textMuted)),
                  const SizedBox(width: 12),
                  Text('$balance',
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800, color: p.accent, fontFamily: 'Outfit')),
                  const SizedBox(width: 6),
                  Text('Fit Coins', style: TextStyle(color: p.textMuted, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Demo rewards catalog — redemptions are recorded locally in this prototype and do not send '
              'real gift cards, devices, or subscriptions.',
              style: TextStyle(color: p.textDim, fontSize: 11.5),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              final cols = responsiveColumns(constraints.maxWidth, desktop: 3, tablet: 2, mobile: 1);
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.15,
                children: [
                  for (final r in rewardsCatalog)
                    _RewardCard(
                      reward: r,
                      affordable: balance >= r.cost,
                      onRedeem: () {
                        final ok = appState.redeem(r);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? 'Redeemed: ${r.name} for ${r.cost} Fit Coins.'
                              : 'Not enough Fit Coins for ${r.name} yet.'),
                        ));
                      },
                    ),
                ],
              );
            }),
            const SizedBox(height: 24),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My redeemed rewards', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  if (sortedRedemptions.isEmpty)
                    Text('You have not redeemed any rewards yet.', style: TextStyle(color: p.textDim))
                  else
                    for (final r in sortedRedemptions)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(r.name, style: const TextStyle(fontSize: 13))),
                            Text('${r.cost} coins', style: TextStyle(color: p.textMuted, fontSize: 12.5)),
                            const SizedBox(width: 10),
                            Text('${r.timestamp.month}/${r.timestamp.day}/${r.timestamp.year}',
                                style: TextStyle(color: p.textDim, fontSize: 12.5)),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RewardCard extends StatelessWidget {
  final Reward reward;
  final bool affordable;
  final VoidCallback onRedeem;

  const _RewardCard({required this.reward, required this.affordable, required this.onRedeem});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Opacity(
      opacity: affordable ? 1 : 0.6,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.border),
          boxShadow: [BoxShadow(color: p.cardShadow, blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(rewardCategoryImage(reward.category), width: 44, height: 44),
            const SizedBox(height: 4),
            Text(reward.category.toUpperCase(),
                style:
                    TextStyle(fontSize: 10, color: p.textDim, letterSpacing: 0.3, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Expanded(
              child: Text(reward.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
            Text('${reward.cost} coins',
                style: TextStyle(color: p.accent, fontWeight: FontWeight.w800, fontFamily: 'Outfit')),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: affordable ? onRedeem : null,
                child: Text(affordable ? 'Redeem' : 'Not enough coins', style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
